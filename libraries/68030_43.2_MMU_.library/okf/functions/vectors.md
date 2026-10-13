# 68030.library 43.2 (MMU) — vectors & init flow

## Function table (data+0x10, 37 entries)

| LVO  | code off | function |
|------|----------|----------|
| -6   | 0x1ac    | LibOpen: `bclr #3,flags14; addq #1,opencnt32; ret base` |
| -12  | 0x1ba    | LibClose: `if(opencnt) opencnt--; ret 0` (never expunges) |
| -18  | 0x1c8    | LibExpunge stub: `moveq #0,d0; rts` |
| -24  | 0x1c8    | same null stub |
| -30..-216 | 0x22 | dead vectors: `pea 0x3f000001; bsr helper; moveq#0; rts` — every call raises Alert(0x3f000001) then returns 0 |
| -222 | 0x248    | **FPUControl(d0=flags, d1=mask)**: Disable; `old=lib[34]; lib[34]=(old&~mask)|(flags&mask)`; Enable; returns old |
| (-228..-246 tail entries) | 0x22 | more dead stubs to the -1 terminator |

The functab terminator `-1` is at data+0xa4.

## LibInit (code+0x4a)

Entry contract: `d0` = allocated library base, `a0` = seglist,
`a6` = ExecBase. a4 = base throughout.  Byte-identical to the
40.1 init except `lib_Version=43`, `lib_Revision=2` and the
shifted patch-table/slot operands (patch_sysbase at
code+0x3e4, patch_lib at code+0x45c, table A at data+0x178,
table B at data+0x184).

1. `lib+48 = SysBase`, `lib+44 = seglist`.
2. CPU gate on the **AttnFlags low byte** (`a6@(297)`):
   `btst #3` → fail (AFF_68040 set ⇒ 040/060 rejected),
   `btst #2` → fail (AFF_68030 required). Exactly-a-68030
   gate (any bits above the 030 flag, e.g. 040/060 set,
   fail the `btst #3`; a bare 68000/010/020 lacks bit 2).
3. `btst #4` (AFF_68881) — if clear, `bset #0, lib+43`
   (CPUFLAG_NO68881).
4. Header fill: `ln_Type=9`, `lib_Flags=6` (SUMUSED|CHANGED),
   `ln_Name=data+0xa8` ("68030.library"),
   `lib_IdString=data+0x127`, `lib_Version=43`,
   `lib_Revision=2`, `lib+36 = 'THOR'`.
5. `expansion.library` v37 → lib+56; fail → Alert 0x3f02800a.
6. `utility.library` v37 → lib+52; fail → Alert 0x3f02800c.
7. Forbid; `FindName(&SysBase->DeviceList, "input.device")`
   → lib+72; Permit. NULL → Alert 0x3f028021.
8. `a6=lib`: **PatchTable A** (code+0x274 — the ColdReboot
   slot): Disable, SetFunction(exec,-726,pf_coldreboot), save
   old into the slot at fn-4, Enable.
9. `OpenLibrary("mmu.library",0)` → lib+68.  NULL →
   Alert 0x3f02803e, **UnpatchTable A** (restore ColdReboot),
   then cleanup.
10. `a6=mmub; GetMMUType()` (mmu.library LVO -54) — returns 0
    ⇒ `bset #1, lib+43` (CPUFLAG_NOMMU).  **Quirk: called even
    when OpenLibrary failed** (a6=0 → jsr into low memory).
11. If NO68881 clear: `a6=lib; InstallExcVecs` (code+0x420):
    `Supervisor(super_excvec)` then `CacheClearU`.
12. `a6=lib`: **PatchTable B** (code+0x29a) — the ten-vector
    install (see below).
13. Return `a4` = library base.

### Cleanup/fail tail

- CloseLibrary on each non-NULL of lib+68 (mmu), lib+52
  (utility), lib+56 (expansion).
- `FreeMem(base - lib_NegSize, NegSize + PosSize)` — frees the
  whole MakeLibrary allocation.  **No exec/Remove** is done —
  at init-fail time the library is not yet in the lib list.
- Return NULL.  The CPU-gate fail jumps straight into this
  tail without alerting.

## Alert helper (code+0x30)

`pea code; bsr helper`: pushes regs, `d7 = arg`,
`a6 = lib+48` (SysBase), `a5 = 0`, `jsr -108` (Alert), pops
regs, slides the return address over the pushed code, rts.
Also used by the dead-vector stub (0x22) with 0x3f000001 and
by pf_coldreboot with 0x3f000002.

## Patch tables

Record format (words): `{liboff, vecoff, fnoff}` — liboff is
the offset inside Lib68030Base of the pointer to the target
library base (`a4@(0,d0:w)`), vecoff is the signed LVO, fnoff
is the offset into the patch region (first long of the table
is the region base pointer).  A `liboff` of 0 makes
`a4@(0)=a4` itself the base; `vecoff == 0` ends the table.
For liboff==0 records the patcher stores `0` at **fn** (not
fn-4) — a shipped quirk.

### Table A (data+0x178)

| liboff | vecoff | fnoff | meaning |
|--------|--------|-------|---------|
| 48 | -726 | +4 | SysBase ColdReboot → pf_coldreboot |

### Table B (data+0x184) — 10 records (was 11 in 40.1)

| liboff | vecoff | fnoff | target |
|--------|--------|-------|--------|
| 48 | -396 | +0x70 | exec AddLibrary → CacheClearU trampoline |
| 48 | -414 | +0x82 | exec CloseLibrary → trampoline |
| 48 | -432 | +0x94 | exec AddDevice → trampoline |
| 48 | -486 | +0xa6 | exec AddResource → trampoline |
| 48 | -282 | +0xb8 | exec AddTask → trampoline |
| 48 | -168 | +0xca | exec AddIntServer → trampoline (moveml d0/a1) |
| 48 | -162 | +0x12c | exec SetIntVector → trampoline (moveml d0/a1) |
| 48 | -372 | +0xe0 | exec GetMsg → pf_getmsg (INTENA reimpl.) |
| 48 | -36  | +0x11c | **exec internal slot -36** → pf_lvo36 |
| 72 | -30  | +0x14a | input.device BeginIO → pf_beginio |

43.2 drops the 40.1 record `liboff 56, -30` (expansion
AddConfigDev) and adds `liboff 48, -36` — an unpublished exec
jump-table slot (between Supervisor -30 and InitCode -72;
exec-internal dispatch code, not in the NDK lvo list).

### Table C (data+0x1c8) — 68881 exception vectors

Read by `super_excvec` directly, not via SetFunction.
Record format: `{newfn .long, vbroff .word, saveoff .word}`:

| newfn | vbr off | vector | saveoff | flag bit |
|-------|---------|--------|---------|----------|
| pf_trap5 | 0xd4 | 53 FPOverflow     | lib+0x64 | 4 |
| pf_trap3 | 0xcc | 51 FPUnderflow    | lib+0x5c | 3 |
| pf_trap6 | 0xd8 | 54 FPSignalNaN    | lib+0x68 | 5 |
| pf_trap4 | 0xd0 | 52 FPOperandError | lib+0x60 | 6 |
| pf_trap0 | 0xc0 | 48 FPBSUN         | lib+0x50 | 0 |
| pf_trap1 | 0xc4 | 49 FPInexact      | lib+0x54 | 1 |
| pf_trap2 | 0xc8 | 50 FPDivZero      | lib+0x58 | 2 |

The pf_trapN names follow the flag bit N in the FPUFlags byte
(lib+34), not the vector number: flag bit → handler → vector
mapping is bit0→48 BSUN, bit1→49 Inexact, bit2→50 DivZero,
bit3→51 Underflow, bit4→53 Overflow, bit5→54 SNAN,
bit6→52 OperandError.

`super_excvec`: `ori #0x700,sr` (raise IPL), `movec vbr,a0`,
walks the table — saves `a0@(vbroff)` into `a4@(saveoff)`,
writes the handler to **both** `a0@(vbroff)` (VBR table) and
`@(vbroff)` (absolute low memory, covering VBR==0), then `rte`.
Identical to 40.1.

## Patch stub semantics

- **pf_coldreboot**: Disable; CacheControl(0,-1); then
  `Supervisor(super_coldreboot)`: `ori #0x700,sr`; **030
  PMMU**: `pmove %sp@,%tt0` and `pmove %sp@,%tt1` with
  `0x00ff8707` (translation off — unconditional); then if
  the "no MMU" flag (lib+43 bit 1) is **clear**,
  `pmove %sp@,%tc` with 0 (PMMU off); `moveq #0,d0;
  movec d0,cacr; movec d0,vbr` (**new in 43.2** — clears the
  caches and relocates the vector base before the jump);
  ROM base = `0x1000000 - *(0x1000000-20)`, reset PC =
  `*(rombase+4)-2`, then a forward/backward `bras` pair
  bracketing `reset; jmp a0@`.  If it ever returns:
  Alert(0x3f000002), Enable, rts.
- **CacheClearU trampolines** (AddLibrary/-396,
  CloseLibrary/-414, AddDevice/-432, AddResource/-486,
  AddTask/-282): push saved old-vector, push args, call
  exec CacheClearU, pop args, `rts` into the old vector.
- **AddIntServer/-168, SetIntVector/-162**: same but save
  d0/a1 explicitly (moveml variant) — interrupt data args.
- **pf_getmsg** (-372): hand-rolled GetMsg — **43.2 early
  out**: `lea a0@(20),a0` (&mp_MsgList.lh_Head), then
  `lh_TailPred == &lh_Head` ⇒ `moveq #0,d0; rts` before
  touching INTENA.  Otherwise `INTENA=0x4000` (master off),
  unlink `lh_Head` **only if head->ln_Succ != 0** (the
  single-element quirk from 40.1 remains — see defects),
  `IDNestCnt`+/− at SysBase+294, restore INTENA when the
  counter goes non-negative.
- **pf_lvo36** (exec -36, **new**): push saved old-vector,
  `tstw $dff01e` (INTREQR — flags result unused), `rts` into
  the old vector.  Effectively a passthrough with a vestigial
  Paula interrupt-request read.
- **pf_beginio** (input.device -30): push saved BeginIO;
  if `io_Command == 9` (IND_ADDHANDLER) run CacheClearU via
  the stored SysBase; tail-call old BeginIO.
- **pf_trapN** (68881 exceptions): `btst #N, patch_lib@(22)` —
  the byte at lib+34 is the FPUControl flag byte; if the flag
  bit is set, fall into `pf_fsavefix` (68881 `fsave`/`frestore`
  frame fixup + `rte`); otherwise push the saved vector from
  `patch_lib@(saveoff)` and `rts` into it (tail-call original
  handler).

## mmu.library

Only `GetMMUType` (LVO -54) is used; a 0 result merely sets
the NOMMU flag bit — the library stays resident regardless.
