---
type: Algorithm
title: xpkPWPK codec (PowerPacker LZ)
---

# Codec

PowerPacker-style LZ77, big-endian bit order, ctx ~0x31000 bytes.

## Pack (LAB_0018, code+0x21e)

1. Clear tab2 (2<<e3 longs) and tab1 (0x30000 bytes = 2-level
   hash: 16-bit context + byte-suffix top byte).
2. Seed hash chains over first min(2<<e3, srclen) bytes.
3. Greedy loop: walk chain at hash(cur, next byte); longest match
   wins; lengths 2-5 use direct classes, 6-12 coded `len-5`,
   >=13 unary groups of 7.  Literal = `1`+8 bits.
   Match emitted as: class bits, offset bits (d1), then
   extra-length bits via LAB_0041/0042 writers.
4. Bit writer D5 accumulates via ADDX; on carry-out flushes a
   longword to (A6)+.  Overflow guard: `cmpal a5` (dst+srclen-8)
   -> longjmp to saved SP (ctx+50), returns -1 -> caller -17.
5. Epilogue: trailing longs — reversed bit-length | (srclen<<8)
   plus optional mode long; userdata path appends checksum and
   XOR-encrypts the payload with LAB_006C.

## Unpack (LAB_0050, code+0x666)

Backwards bit reader (MOVE.L -(A0) + ROXR).  Two 256-byte
bit-reverse tables (code+0x5b4, +0x634) byte-reverse the literal.
Match class decoded by counting `0`-run + fixed bits; jump into
the unrolled `CMPM` copy expansion at LAB_005D/0063 (code+0x6a8,
+0x722, emitted as raw DC.L — 4-instr `lsl/addx/movemw` slots,
indexed by 13-modeclass*4*... step = modeclass from table at
code+0x59c).

Mode table (code+0x59c, 4B/mode): mode0 {9,9,9,9}, mode1
{9,10,10,10}, mode2 {9,10,11,11}, mode3 {9,10,12,12}, mode4
{9,10,12,13} — byte0 is pad, bytes 1..3 = hash exponents e1..e3.
