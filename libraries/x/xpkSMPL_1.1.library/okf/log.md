# log

- full IRA/objdump decode of the 1,568-byte hunk; all 10 vectors
  resolved; LONG functab marker + word offsets verified.
- codec: dynamic Huffman over 8-bit deltas; 24-byte arena nodes,
  sorted-list merge, roxrl code accumulation (leaf edge -> LSB).
- notable corrections during reconstruction:
  - `movew a6@+,d7` REPLACES the reader's low word (not |=); wrong
    model desynced every boundary-crossing read.
  - roxrl edge accumulation order -- leaf edge ends LSB (initial
    `|= bit>>len` reversal produced non-prefix-free code sets for
    mixed lengths while still round-tripping for uniform lengths).
  - len>=15 symbol codes use the shared 0x3ec splitting emitter,
    not the inline path.
  - node records modeled as wk-relative ULONG offsets to keep the
    24-byte layout host-portable (32-bit ULONG fields).
- host verification: 3000 pack iterations byte-identical to an
  independent model; 887 full-coverage round-trips clean; sparse
  histograms reproduce the shipped desynced stream byte-for-byte.
- shipped defects documented in findings/defects.md -- most
  importantly: streams are only valid when all 256 delta values
  occur in the input (the len-0 `moveq #0,d7` wipe corrupts
  otherwise), and decoding a corrupt stream walks wild pointers.
- m68k build: all 10 vectors resolve; LibInit word-aligned via
  `.even` before it.
