---
type: Algorithm
title: xpkNUKE 1.1 stream format
timestamp: 2026-10-15T00:00:00Z
---

# NUKE 1.1 packed format

LZ77 with hash chains (same family as later NUKEs, different
emit tables).  Output = four interleaved forward bit streams
followed by the literal region.

## Emit side (code+0x52e, writer at 0x434)

Bit streams share a "delayed slot" scheme: four write pointers
(ctx+64..79) each reserve the next free position in the output
(outcur, ctx+16) and the *previous* reservation receives the
accumulator when the stream's bit counter underflows.  Seed slots
point at ctx+80 scratch so the initial all-zero flushes are
absorbed inside the ctx block.

- s1 (ctx+44 ctr / +52 acc.w): 1 flag bit per token —
  0 literal(s) flushed / 1 match.
- s2 (ctx+46 / +54): 2-bit codes (length class, literal-run size).
- s3 (ctx+48 / +56.l, rorl #4): nibble = offset-class code.
- s4 (ctx+50 / +60.l, asll d7): variable extra offset bits.

Literals are written *backwards* starting at dst+OutBufLen-4
(ctx+20 litptr).  Final flush (0x8ec) emits the partial accs into
their slots; the tail routine (0x950) pads with 0xfb bytes until
(outcur+litcount) is long-aligned, copies the literal block
forward to right after the streams, and returns the total length.

Match search: hash = (src[i-1]<<8 | src[i]) word-indexed head
table tab1 (64K w); tab2 (32K w) prev-chain, lazily cleared via a
frontier pointer (ctx+28); chain walk limited to window 0x2aa0 and
srcend = src+inlen.

## Decode side (code+0x992)

Reads s1 flag bit (d2): 0 -> copy one literal backwards from the
packed tail (a4@-); 1 -> 2 bits (d3) select the match-length
decoding path through the copy-count table (jmp pc@(off,d0:w)
dispatch at 0x9f4/0xa14/0xa9e), then a 4-bit nibble (d4, roxr)
indexes the offset-class table at code+0x3d4:
a6+0 = bit counts, a6+0x14 = base offsets, a6+0x28 = extra-bits
-> jump offsets; extra bits come from s4.  Loops until the dst
end (OutBuf + caller-supplied xsp_OutLen) is reached.

## Table layout (code+0x36c..0x433)

- 0x36c seltab: min(len,3)*2 -> word index into class tables
- 0x374..: per-class triples — 16 base-offset words,
  +0x20 shift/nbits words, +0x40 nibble codes
- 0x3d4..: decoder table (counts @+0, bases @+0x14, jump offs @+0x28)
- 0x3f4..: copy-dispatch jump offsets into the unrolled moveb loops
