# 68020.library 46.3 — Findings / Defects

## Quirks carried from 43.2

- **Ln_IdString points past `$VER: `** — the version cookie sits
  immediately before the id string so `$VER:` scanners still work.
- **FPUFlags byte aliases the revision word's high byte** — FPUControl
  and the exception handlers operate on lib+34 (the high byte of
  `lib_Revision`).  Revision ships as 0x0003, so the flag byte is 0 and
  FPU handlers initially tail-call the saved vectors.
- **PatchTable's missing-lib write** — when a patch target's
  library-base slot is NULL, PatchTable writes 0 to `fn` (the stub's
  first bytes), not to `fn-4`'s old-vector slot.  Never triggered in
  practice (all targets are found before patching).
- **GetMsg single-element quirk** — a port list whose head node's
  ln_Succ is NULL returns 0 *without* unlinking the node, matching
  exec's own quirk family.
- **exec -36 trampoline reads INTREQR then discards it** — the `tstw
  $dff01e` sets flags that the following `rts` never consumes.
- **Expunge is a permanent no-op** — `moveq #0/rts`; the driver can
  never be expunged once resident.  LibClose also never expunges.
- **Silent CPU reject** — a non-68020 host gets no alert at all, just
  the FreeMem of neg+possize (338 bytes) and a NULL return.
- **Dead alert block** — `pea 0x3f028005; bra alert-helper` at
  code+0x15c is unreachable; no branch targets it.
- **"mathieeedoubbas.library" / "mathieeesingbas.library" strings are
  dead data** — carried in the data hunk, never opened.

## New in 46.3

- **InitStage2 runs even when mmu.library calls are meaningless** —
  the mmu -150/-282 object copy and the p5emu.library expunge execute
  unconditionally after PatchTable(B).  If mmu -150 returns NULL the
  -282 calls are skipped, but the expunge still runs.
- **Supervisor({nop;rte}) called only when NOMMU** — when GetMMUType
  reports NONE the init calls Supervisor on a `nop;rte` body: a
  privileged no-op round-trip whose only effect is a supervisor-mode
  entry/exit.  Purpose unclear (possibly a pipeline/stack warm-up or a
  Probe for Supervisor availability).
- **p5emu.library expunged with a foreign a1** — the p5emu -24 vector
  is invoked with `a1 = 68020.library`'s own base.  Standard expunges
  ignore a1; if p5emu's expunge interprets it (e.g. as a seglist) the
  result depends on p5emu internals.
- **ColdReboot reset gating on the patch code's own address** — the
  `reset` instruction is skipped when the loaded library code is below
  `0x200000` (2 MB).  On machines where the library loads into chip or
  24-bit memory, ColdReboot jumps to the ROM reset PC *without*
  resetting peripherals first.
- **ColdReboot dead bytes** — `nop; .word 0` between the two `bra.s`
  hops in the reset tail are unreachable, as shipped.
- **Private base grew by an unused longword** — dataSize 0x74 vs 0x70;
  lib+0x50 is never touched, TrapSave shifted to 0x54-0x6c.

## Verification notes

machine68k differential oracle (`work/oracle.py`): init sequence,
alert codes, patch installation order, supervisor calls, mmu.library
call sequence, p5emu expunge call, exception-vector install, ColdReboot
trap sequence, GetMsg early-out, dead-vector alert, FPUControl — all
identical between the original and the reconstruction across the full
flag/failure matrix (9 configurations plus vector probes).
