---
file: defects
---
# Findings

## vs the 020 sibling (byte diff of hunk bodies)

- Codegen: all six 64-bit `mulu.l` ops (68060-unimplemented, would
  trap) are inlined by the compiler as 12-byte two-`mulu.w`
  expansions. Four `mulul d2,d0` sites (020 @0x52c encoder,
  @0xce2/@0xcf8/@0xd1c decoder) become
  `movel d2,d1 / muluw d4,d0 / swap d1 / muluw d4,d1 / swap d1 /
  addl d1,d0`; two `mulul d2,d6` sites (020 @0x53c/@0xd2e) become
  `movel d2,d6 / muluw d4,d6 / swap d2 / muluw d4,d2 / swap d2 /
  addl d2,d6`. +8B each => decoder code shifted +0x10, tail data
  +0x2e; all bsr/branch/pc-rel displacements retargeted.
- functab -54 offset 0x069e -> 0x06ae (only functab change).
- lname 'Shrink 020+ V3.0' -> 'Shrink 020-060 V3.0' (+3B); tail
  data 0x236 -> 0x238B, trailing pad byte differs.
- All 23 RELOC32 head entries identical; all 14 tail entries +0x2e.
- initfn CPU gate is byte-identical: `btst #1,SYSB+0x129` (tests
  the AttnFlags low byte, i.e. AFF_68020) — the 060 build kept the
  020+ check rather than gating on AFB_68060; passes because 060
  systems set all lower AttnFlags bits.

## inherited quirks (same as 020)

- initfn requires AttnFlags bit 1 set (68020+) — on a bare 68000
  it branches to the +0 `moveq#0/rts` stub and MakeLibrary fails.
- Stream flag byte (first output byte): packer emits 1 for a fresh
  model, 2 for a continuation chunk when xsp+0x34 keeps a live
  encoder ctx. Unpacker accepts flags <= 2; flag 1 resets the
  decoder model, 0/2 continue on the ctx at xsp+0x34; flag >= 3 ->
  -26. Multi-chunk continuation round-trips only when BOTH sides
  keep their ctx.
- Unpacker trusts xsp+0x10 (expected unpacked length) and never
  bounds-checks the destination; no dst-length field is read.
- -42 ctx-free and -60 alias the same +0x128 routine.
- Calling -48 (ctx reinit) or -42/-60 with an xsp whose +0x34 is
  not a real ctx makes it dereference the garbage pointer.
