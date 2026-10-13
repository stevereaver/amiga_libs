# 68030.library 40.1 (MMU) — vectors & init flow

## Function table (data+0x10, 37 entries)

| LVO  | code off | function |
|------|----------|----------|
| -6   | 0x1ac    | LibOpen: `bclr #3,flags14; addq #1,opencnt32; ret base` |
| -12  | 0x1ba    | LibClose: `if(opencnt) opencnt--; ret 0` (never expunges) |
| -18  | 0x1c8    | LibExpunge stub: `moveq #0,d0; rts` |
| -24  | 0x1c8    | same null stub |
| -30..-216 | 0x22 | dead vectors: `pea 0x3f000001; bsr helper; moveq#0; rts` — every call raises Alert(AN_0x3f000001) then returns 0 |
| -222 | 0x248    | **FPUControl(d0=flags, d1=mask)**: Disable; `old=lib[34]; lib[34]=(old&~mask)|(flags&mask)`; Enable; returns old |
| (-228..-246 tail entries) | 0x22 | more dead stubs to the -1 terminator |

The functab terminator `-1` is at data+0xa4.

## LibInit (code+0x4a)

Entry contract: `d0` = allocated library base, `a0` = seglist,
`a6` = ExecBase. a4 = base throughout.  Same flow as the
68020 40.1 sibling; only the gate bits, the
patch_sysbase/patch_lib operands (code+0x3ca / code+0x464)
and the supervisor body differ.

1. `lib+48 = SysBase`, `lib+44 = seglist`.
2. CPU gate on the **AttnFlags low byte** (`a6@(297)`):
   `btst #3` → fail (AFF_68040 set ⇒ 040/060 rejected),
   `btst #2` → fail (AFF_68030 required). Exactly-a-68030 gate.
3. `btst #4` (AFF_68881) — if clear, `bset #0, lib+43`
   (CPUFLAG_NO68881).
4. Header fill: `ln_Type=9`, `lib_Flags=6` (SUMUSED|CHANGED),
   `ln_Name=data+0xa8` ("68030.library"),
   `lib_IdString=data+0x127`, `lib_Version=40`,
   `lib_Revision=1`, `lib+36 = 'THOR'`.
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
    ⇒ `bset #1, lib+43` (CPUFLAG_NOMMU).
11. If NO68881 clear: `a6=lib; InstallExcVecs` (code+0x410):
    `Supervisor(super_excvec)` then `CacheClearU`.
12. `a6=lib`: **PatchTable B** (code+0x29a) — the ten-vector
    install (see below).
13. Return `a4` = library base.

### Cleanup/fail tail (code+0x164..0x1aa)

- CloseLibrary on each non-NULL of lib+68 (mmu), lib+52
  (utility), lib+56 (expansion).
- `FreeMem(base - lib_NegSize, NegSize + PosSize)` — frees the
  whole MakeLibrary allocation.  **No exec/Remove** is done —
  at init-fail time the library is not yet in the lib list.
- `a4 = 0`; return NULL.
- The CPU-gate fail (step 2) jumps straight into this tail
  without alerting.

## Alert helper (code+0x30)

`pea code; bsr helper`: pushes regs, `d7 = arg`,
`a6 = lib+48` (SysBase), `a5 = 0`, `jsr -108` (Alert), pops
regs, slides the return address over the pushed code, rts.
Also used by the dead-vector stub (0x22) with 0x3f000001 and
by pf_coldreboot / pf_addconfigdev with their own codes.

## Patch tables

Record format (words): `{liboff, vecoff, fnoff}` — liboff is
the offset inside Lib68020Base of the pointer to the target
library base (`a4@(0,d0:w)`), vecoff is the signed LVO, fnoff
is the offset into the patch region (first long of the table
is the region base pointer).  A `liboff` of 0 makes
`a4@(0)=a4` itself the base (this library); `vecoff == 0`
ends the table.  For liboff==0 records the patcher stores
`0` at **fn** (not fn-4) — a shipped quirk.

### Table A (data+0x1c4)

| liboff | vecoff | fnoff | meaning |
|--------|--------|-------|---------|
| 48 | -726 | +4 | SysBase ColdReboot → pf_coldreboot |

### Table B (data+0x1d0)

| liboff | vecoff | fnoff | target |
|--------|--------|-------|--------|
| 48 | -396 | +0x6e | exec AddLibrary → CacheClearU trampoline |
| 48 | -414 | +0x80 | exec CloseLibrary → trampoline |
| 48 | -432 | +0x92 | exec AddDevice → trampoline |
| 48 | -486 | +0xa4 | exec AddResource → trampoline |
| 48 | -282 | +0xb6 | exec AddTask → trampoline |
| 48 | -168 | +0xc8 | exec AddIntServer → trampoline (moveml d0/a1) |
| 48 | -162 | +0x112 | exec SetIntVector → trampoline (moveml d0/a1) |
| 48 | -372 | +0xde | exec GetMsg → pf_getmsg (INTENA reimpl.) |
| 72 | -30  | +0x130 | input.device BeginIO → pf_beginio |
| 56 | -30  | +0x152 | expansion AddConfigDev → pf_addconfigdev |

### Table C (data+0x1f0) — 68881 exception vectors

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

VBR-relative offsets 0xc0..0xd8 = vectors 48..54, the
68881/68882 FPU exception vectors.  The pf_trapN names follow
the flag bit N in the FPUFlags byte (lib+34), not the vector
number: bit0→48 BSUN, bit1→49 Inexact, bit2→50 DivZero,
bit3→51 Underflow, bit4→53 Overflow, bit5→54 SNAN,
bit6→52 OperandError.

`super_excvec`: `ori #0x700,sr` (raise IPL), `movec vbr,a0`,
walks the table — saves `a0@(vbroff)` into `a4@(saveoff)`,
writes the handler to **both** `a0@(vbroff)` (VBR table) and
`@(vbroff)` (absolute low memory, covering VBR==0), then `rte`.

## Patch stub semantics

- **pf_coldreboot**: Disable; CacheControl(0,-1) (all caches
  off); Supervisor(super_coldreboot): `ori #0x700,sr`; if
  MMU-flag clear `pmove %sp@,%tc; pmove %sp@,%tt0;
  pmove %sp@,%tt1` (030 PMMU: translation + both transparent
  windows off); ROM base = `0x1000000 - *(0x1000000-20)`,
  reset PC = `*(rombase+4)`, then `bras` over a dead word
  into `reset; jmp a0@` — jumps into the ROM reset routine
  after resetting peripherals.  If it ever returns:
  Alert(0x3f000002), Enable, rts.
- **CacheClearU trampolines** (AddLibrary/-396,
  CloseLibrary/-414, AddDevice/-432, AddResource/-486,
  AddTask/-282): push saved old-vector, push args, call
  exec CacheClearU, pop args, `rts` into the old vector —
  so every library/device/resource/task registration flushes
  the 020 caches.
- **AddIntServer/-168, SetIntVector/-162**: same but save
  d0/a1 explicitly (moveml variant) — interrupt data args.
- **pf_getmsg** (-372): hand-rolled GetMsg — `INTENA=0x4000`
  (master off), unlink `lh_Head` **only if head->ln_Succ != 0**
  (see defects), `IDNestCnt`+/− at SysBase+294, restore INTENA
  when the counter goes non-negative.
- **pf_beginio** (input.device -30): push saved BeginIO;
  if `io_Command == 9` (IND_ADDHANDLER) run CacheClearU via
  the stored SysBase; tail-call old BeginIO.
- **pf_addconfigdev** (expansion -30): push old vector;
  Alert(0x3f000015) (recoverable — a "board rejected" marker);
  tail-call old AddConfigDev.
- **pf_trapN** (68881 exceptions): `btst #N, patch_lib@(22)` — the
  byte at lib+34 is the FPUControl flag byte; if the flag bit
  is set, fall into `pf_fsavefix` (68881 `fsave`/`frestore`
  frame fixup + `rte`); otherwise push the saved vector from
  `patch_lib@(0x50+N*4)` and `rts` into it (tail-call
  original handler).

## mmu.library

Only `GetMMUType` (LVO -54) is used; a 0 result merely sets
the NOMMU flag bit — the library stays resident regardless.
