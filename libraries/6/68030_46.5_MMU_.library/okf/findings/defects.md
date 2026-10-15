# 68030.library 46.5 — Findings / Defects

## Quirks shared with the 68020 siblings

- **ln_IdString points past `$VER: `** — the version cookie sits
  immediately before the id string so `$VER:` scanners still work.
- **FPUFlags byte aliases the revision word's high byte** — FPUControl
  and the exception handlers operate on lib+34 (the high byte of
  `lib_Revision`).  Revision ships as 0x0005, so the flag byte is 0 and
  FPU handlers initially tail-call the saved vectors.
- **PatchTable's missing-lib write** — when a patch target's
  library-base slot is NULL, PatchTable writes 0 to `fn` (the stub's
  first bytes), not to `fn-4`'s old-vector slot.  Never triggered in
  practice (all targets are found before patching).
- **GetMsg single-element quirk** — a port list whose head node's
  ln_Succ is NULL returns 0 *without* unlinking the node.
- **exec -36 trampoline reads INTREQR then discards it** — the `tstw
  $dff01e` sets flags that the following `rts` never consumes.
- **Expunge is a permanent no-op** — `moveq #0/rts`; the driver can
  never be expunged once resident.  LibClose also never expunges.
- **Silent CPU reject** — a non-68030 host gets no alert at all, just
  the FreeMem of neg+pos size and a NULL return.
- **Dead alert block** — `pea 0x3f028005; bra alert-helper` at
  code+0x16c is unreachable; no branch targets it.
- **"mathieeedoubbas.library" / "mathieeesingbas.library" strings are
  dead data** — carried in the data hunk, never opened.
- **The post-PatchTable helpers run even when mmu.library calls are
  meaningless** — the mmu -150/-282 object copy, the init-time
  CacheControl(0x2101,0x2101) and the p5emu.library expunge execute
  unconditionally after PatchTable(B).  If mmu -150 returns NULL the
  -282 calls are skipped, but CacheControl and the expunge still run.
- **p5emu.library expunged with a foreign a1** — the p5emu -24 vector
  is invoked with `a1 = 68030.library`'s own base.  Standard expunges
  ignore a1; if p5emu's expunge interprets it (e.g. as a seglist) the
  result depends on p5emu internals.
- **ColdReboot reset gating on the patch code's own address** — the
  `reset` instruction is skipped when the loaded library code is below
  `0x200000` (2 MB).  On machines where the library loads into chip or
  24-bit memory, ColdReboot jumps to the ROM reset PC *without*
  resetting peripherals first.
- **ColdReboot dead bytes** — `nop; .word 0` between the two `bra.s`
  hops in the reset tail are unreachable, as shipped.
- **Private base pad** — lib+0x50 is never touched (the size bump from
  0x70 to 0x74 happened back at 46.3 and just re-aligned TrapSave).
- **Init-time CacheControl(0x2101,0x2101) is unconditional** — new in
  46.5: the driver force-enables I-cache, D-cache and write-allocate
  mode on every boot regardless of what exec or mmu.library wanted,
  which on a 68030 silently enables the data cache + burst mode.

## 68030-specific observations

- **TT-register writes are unconditional in ColdReboot** —
  `super_coldreboot` always programs TT0=TT1=0x00ff8707 before
  consulting CPUFlags bit1; only the `pmove tc` (PMMU disable) is
  gated on the NOMMU flag.  The NOMMU Supervisor call in init also
  writes TT0=0x00008514 / TT1=0x00ff0125 — different constants from
  the ColdReboot path.
- **`pmove` operand order looks odd but is correct** — super_tt pushes
  0x8514, pmove's it to tt0, *overwrites the same stack slot* with
  0xff0125 and pmove's that to tt1; the ColdReboot version pushes
  0xff8707 once and pmove's it to *both* tt0 and tt1.
- **Exception handlers write two vector tables** — `218a 0190` is an
  absolute-indexed write to the raw byte offset (the VBR=0 low-memory
  mirror), in addition to `vbr[d0]`; verified empirically.
- **Trap4's flag bit is out of order** — FPOperandErr (vec 52) uses
  flag bit 6 while OperandErr-adjacent traps use bits 3-5; the
  excvec table and handler bits agree, so FPUControl callers must set
  bit6 to enable it.  (Same as the 68020 builds.)

## Verification notes

machine68k differential oracle (`work/oracle.py`, CPUType.M68030):
init sequence (incl. the new init-time `cachecontrol` call between
the mmu -282 pair and the p5emu expunge), alert codes, patch
installation order, supervisor calls (excvec install + TT writes),
mmu.library call sequence, p5emu expunge call, exception-vector
install into VBR, ColdReboot trap sequence
(disable→CacheControl(0,-1)→supervisor→Alert 0x3f000002→enable),
dead-vector Alert(0x3f000001), FPUControl merge — all identical
between the original and the reconstruction across the full matrix
(10 cases).
