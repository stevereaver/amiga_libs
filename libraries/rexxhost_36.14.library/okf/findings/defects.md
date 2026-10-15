---
file: defects
---
# Findings

- Unusual resident indirection: rt_Name/rt_IdString/rt_Init all
  relocate into the DATA hunk, which holds pointers back to h0 —
  a two-hop scheme typical of the original Commodore ARexx build.
- Module entry (+0) returns -1 (`moveq #-1,rts`) — nonstandard stub.
- Several vectors echo back the caller's A0 argument unchanged.
- The single BSS longword at hunk2 is the host/globals state word.
- gas m68k silently drops opcode words for `aN@(-disp)` jsr/jmp
  forms when re-assembling — hunk0 is therefore emitted fully raw.
