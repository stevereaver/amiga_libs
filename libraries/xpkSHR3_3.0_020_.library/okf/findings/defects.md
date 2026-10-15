---
file: defects
---
# Findings

- initfn requires AttnFlags bit 1 set (68020+) — on a bare 68000
  it branches to the +0 `moveq#0/rts` stub and MakeLibrary fails;
  the 020 build ships this guard deliberately.
- Stream flag byte (first output byte): packer emits 1 for a fresh
  model, 2 for a continuation chunk when xsp+0x34 keeps a live
  encoder ctx. Unpacker accepts flags <= 2 (`cmpib #2; bls`,
  0x73e-0x74a); flag 1 resets the decoder model, 0/2 continue on
  the ctx at xsp+0x34; flag >= 3 -> -26. Multi-chunk continuation
  round-trips verified only when BOTH sides keep their ctx.
- Unpacker trusts xsp+0x10 (expected unpacked length) and never
  bounds-checks the destination; no dst-length field is read.
  A flag-2 stream unpacked on a fresh decoder ctx silently
  produces garbage output rather than an error.
- -42 ctx-free and -60 alias the same +0x128 routine.
- Calling -48 (ctx reinit) or -42/-60 with an xsp whose +0x34 is
  not a real ctx makes it dereference the garbage pointer —
  -48 then fills ~8KB via ctx+0x7e4/ctx+0x7ec table pointers and
  can smash low memory.
