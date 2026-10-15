---
file: log
---
# Work log

- 2026-10-15: dg8svx 2.1 — 2-hunk AUTOINIT library (CODE
  0x51a + DATA 0xf longs). Resident+InitTable+code in h0;
  h1 holds 6 base slots, tick stub, tag defaults, fib table.
  RELOC32 49 slots (24->h0, 25->h1, order scrambled). Raw
  .byte x2 + tail-splice fixup; BYTE-IDENTICAL (5556B).
  Oracle traces init, open x2 (5 dep OpenLibrary calls), all
  12 vectors incl. stack-arg -36 and fib decoders, close x2,
  expunge under exec + dos/graphics/toolkit/dgiff/dgaudio
  stubs; 0 invalids; RUNTIME-IDENTICAL.
  Notable: InitData writes ln_Type to +0x0c (dead; clobbered
  by ln_Name long at +0x0a) leaving ln_Type==0.
