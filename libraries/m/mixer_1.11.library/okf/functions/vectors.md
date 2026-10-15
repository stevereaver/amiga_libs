---
file: vectors
---
# Vectors

10 LVOs (-6 .. -60).  Two word-offset functabs; the first four
entries resolve to the same code in both variants:

| LVO | tab A (non-ES1370) | tab B (ES1370) | role |
|-----|--------------------|----------------|------|
| -6  | 0x3be | 0x3be | Open: `bclr #3,lib_Flags` (DELEXP), private OpenCnt @+32 ++, returns a6 |
| -12 | 0x3cc | 0x3cc | Close: OpenCnt-- ; zero+DELEXP check is a dead end — always returns 0 |
| -18 | 0x3de | 0x3de | Expunge: `moveq #0,d0;rts` stub (real expunge @0x3e2 unreachable) |
| -24 | 0x43c | 0x43c | reserved: `moveq #0,d0;rts` |
| -30 | 0x60a -> 0x62a | 0x61a -> 0x646 | returns ptr to a static 16B channel-map table |
| -36 | 0x612 -> 0x63a | 0x622 -> 0x652 | returns ptr to a second channel-map table |
| -42 | 0x69e | 0x69e | set-channel dispatcher: d1=1..17 via jsr table @0x6d4; subfunctions write shadow state @0x65a.. and poke codec via [a5+60] |
| -48 | 0x9e4 | 0x9e4 | get-channel: returns long state[d1-1] from table @0x65a, or -1 |
| -54 | 0xa0c | 0xa44 | raw codec read: framed `jsr [a5+56]` (B: just `ret -1`) |
| -60 | 0xa28 | 0xa44 | raw codec write: framed `jsr [a5+60]` (B: just `ret -1`) |

functab A @h0+0x38e, functab B @h0+0x3a6 — exec relative-offset
form (leading 0xffff word, offsets relative to the table base).
NegSize=60, PosSize(dataSize)=80.

## init-time calls (all trapped by oracle)

- expansion.library OpenLibrary v27; FindConfigDev(a0=0, manuf 2206,
  product) — LVO -72.
- pci.library OpenLibrary v2 or v5 (depends on which ConfigDev
  product answered); LVO -30 FindDevice with the table entry
  word-swapped (d0 = device<<16|vendor, d1 = device, d2 = 0).
- exec: CacheClearU -636, MakeLibrary -84, AddLibrary -396,
  CloseLibrary -414, Forbid -132, Permit -138 (codec writes),
  Remove -252 / FreeMem -210 (dead-code expunge only).
- intuition.library v27 + EasyRequestArgs -588 (fail path only).

## call conventions observed

- -42 set: d1 = channel 1..17, d0 = packed value; writes shadow long
  @0x65a+4*(d1-1) then does the chip codec write.  d1=11/12 corrupt
  the stack (see defects).  >=18 -> -1.
- -48 get: d1 = channel 1..17 -> long state or -1.
- -54/-60: d0 = codec register, d1 = value (write); read returns
  register value (0 with stubbed regs).
- Codec helpers live at [a5+56]/[a5+60], per device index:
  ES1370: 0xa48(ret0)/0xa4c(Forbid+regmap); ES1371/ES5880/Creative-8938:
  0xc1e/0xcbc serial codec; FM801: 0xd4c/0xdf0; SB Live!/Audigy:
  0xe68/0xe78.
