# 68020.library 46.4 — Vectors

The AUTOINIT function table in the data hunk holds 37 absolute
longwords (-1L terminated) -> LVOs -6 .. -222.

| LVO | code+ | name | semantics |
|-----|-------|------|-----------|
| -6  | 0x1c0 | LibOpen | `bclr #3,lib_Flags` (DELEXP), `lib_OpenCnt++`, return lib base in d0 |
| -12 | 0x1ce | LibClose | if `lib_OpenCnt != 0` decrement; always returns 0 (never expunges) |
| -18 | 0x1dc | LibExpunge | `moveq #0,rts` — permanent resident, never expunges |
| -24 | 0x1e  | LibNull | `moveq #0,rts` reserved stub (same as 43.2) |
| -30..-216 | 0x22 | DeadVector | `pea 0x3f000001; bsr alert-helper; moveq #0,rts` — alerts and returns 0 |
| -222 | 0x2ee | FPUControl | atomic read/modify of the flag byte at lib+34 (lib+0x22): `d0&=d1; old=flags; flags=(old&~d1)|d0; return old`. Runs under Disable/Enable. |

## Internal entry points (called only by init)

| code+ | name | semantics |
|-------|------|-----------|
| 0x30 | LibAlertHelper | `[ret][code]` stack frame: `Alert(code)` via ExecBase at lib+48, slides ret over the pushed code |
| 0x4a | LibInit | the init vector (see below) |
| 0x1e0 | PatchTable | `{long codebase, {liboff.w, vecoff.w, fnoff.w}*, 0}`: Disable, SetFunction each, store old vector into `fn-4`; **if liboff slot is NULL, writes 0 to `fn` (over the stub) — shipped quirk** |
| 0x23a | UnpatchTable | same walk; if `fn-4` slot nonzero and target lib present, SetFunction back to the saved vector |
| 0x220 | NommuSuperNop | `Supervisor({nop;rte})` — a no-op privileged round-trip, called only when GetMMUType returned NONE |
| 0x276 | MMUObjectCopy | mmu.library `-150` -> obj; if nonzero, mmu `-282`(obj, `0x83e00403`) -> src and mmu `-282`(obj, `0x83e00405`) -> dst; if dst nonzero, copy 16 bytes src -> dst |
| 0x2c2 | ExpungeP5Emu | Forbid; `FindName(&LibList,"p5emu.library")`; if found call its `-24` vector with a1 = *this* library's base; Permit |
| 0x31c | StoreSlots+PatchA | store ExecBase to `patch_sysbase`, lib base to `patch_lib`, then PatchTable(table A) |
| 0x336 | UnpatchA | UnpatchTable(table A) — used by the mmu-open-fail path |
| 0x342 | PatchB | PatchTable(table B) |

## LibInit sequence (exact)

1. `b_SysBase=a6`, `b_SegList=a0`; AttnFlags: `AFF_68030|beq-fail`, `!AFF_68020|beq-fail`, `!AFF_68881 -> b_CPUFlags |= 1` (NO68881)
2. ln_Type=9, lib_Flags=6, ln_Name, ln_IdString (points **past** `$VER: `), lib_Version=46, lib_Revision=3, magic='THOR'
3. `OpenLibrary("expansion.library",37)` -> lib+0x38; fail -> Alert(0x3f02800a)
4. `OpenLibrary("utility.library",37)` -> lib+0x34; fail -> Alert(0x3f02800c)
5. Forbid; `FindName(&DeviceList,"input.device")` -> lib+0x48; Permit; fail -> Alert(0x3f028021)
6. StoreSlots+PatchA (installs the ColdReboot patch, exec -726)
7. `OpenLibrary("mmu.library",0)` -> lib+0x44; fail -> Alert(0x3f02803e) + UnpatchTable(A) + cleanup
8. `mmu.library/-54` (GetMMUType); returns 0 -> `b_CPUFlags |= 2` (NOMMU)
9. `!NO68881` -> InstallExcVecs (Supervisor write of FPU vectors 48-54 into VBR + low memory, then CacheClearU)
10. PatchTable(B): 10 patches — AddLibrary -396, CloseLibrary -414, AddDevice -432, AddResource -486, AddTask -282, AddIntServer -168, SetIntVector -162, GetMsg -372, exec-internal -36, input.device BeginIO -30
11. `NOMMU` -> Supervisor({nop;rte})
12. MMUObjectCopy (mmu -150/-282)
13. ExpungeP5Emu
14. return lib base

## Patched exec vectors (installed stubs)

All stubs sit in the patch region; each is preceded by a 4-byte slot
that PatchTable fills with the replaced vector.

| vector | stub | behavior |
|--------|------|----------|
| exec -726 ColdReboot | code+0x352 | Disable, CacheControl(0,-1), Supervisor(super_coldreboot); on return Alert(0x3f000002), Enable |
| exec -396/-414/-432/-486/-282 | trampolines | push saved old vector, push a1, CacheClearU (exec -636), pop a1, rts into old vector |
| exec -168 AddIntServer | trampoline | same but moveml d0/a1 around CacheClearU |
| exec -162 SetIntVector | trampoline | same as AddIntServer |
| exec -372 GetMsg | code+0x44a | INTENA-based GetMsg: early out on empty list, master-INTENA off, unlink head, restore |
| exec -36 (internal) | code+0x486 | push old vec, `tstw 0xdff01e` (INTREQR), rts — flag result unused |
| input.device -30 BeginIO | code+0x4b4 | if `io_Command==9` (IND_ADDHANDLER): CacheClearU via ExecBase slot; tail-call old BeginIO |

## ColdReboot supervisor body (code+0x380)

`oriw #0x700,sr`; if !NOMMU `pmove` TC=0 (PMMU off); clear CACR+VBR;
ROM base from `*(0x1000000-20)`, reset PC from `rombase+4`; if the word
before the reset PC is `0x4e70` (reset), back a0 up 2 so the `reset` is
included; then — **new in 46.3/46.4** — `cmpal #0x200000,a1` on the patch
code's own address: if a1 >= 2 MB, execute `reset` then `jmp a0@`;
below 2 MB, `jmp a0@` directly (no peripheral reset).  Two dead bytes
(`nop; 0`) sit between the two `bra.s` hops, as shipped.

## 68881 exception handlers (code+0x524..)

Seven handlers for VBR vectors 48-54 (0xc0..0xd8): each `btst` a flag
bit in lib+34; bit set -> `pf_fsavefix` (fsave frame mark + rte), bit
clear -> push saved original vector (lib+0x54..0x6c) and rts into it.
Order in the exception table: BSUN(c0,bit0), Inexact(c4,bit1),
DivZero(c8,bit2), Underflow(cc,bit3), OperandErr(d0,bit6),
Overflow(d4,bit4), SignalNaN(d8,bit5).
