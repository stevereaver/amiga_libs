# XpksPackChunk (-36)

Packs one chunk, PackBits-style: `count>0` literal header + bytes,
`-count` + byte for repeat runs, 0x00 stream terminator.  Completely
rewritten vs 1.4 (dbra-counted scanners instead of a lit/pend state
machine).

Register plan (after `movem.l (a0),a1-a3` — only THREE params read):

| reg | role |
|-----|------|
| a1 | input cursor |
| a2 | `InBuf + InLen` (inend) |
| a3 | output cursor |
| a4 | `OutBuf + InLen` (**ceiling** — xsp_OutBufLen is never read) |
| a5 | segment start (pending literal base) |
| d1 | current byte / run byte |
| d2 | dbra scan counter, seeded at 124 |
| d0 | scratch / emit length |

Flow: `_seg` starts a segment; two bytes are compared.  An equal pair
enters the run scan (`cmp.b (a1)+,d1 / dbne`, cap 124); a differing
pair enters the literal scan, which walks ahead (two alternating
dbcc loops) until a *triple* of equal bytes appears — then backs up
two so the run starts cleanly — or the counter dies (literal cap).
Emits:

- run: `-len, byte` (tail-run clamped to inend),
- literal: `len, bytes` (`dbf` copy loop),
- end: literal tail (clamped) + `0x00` terminator,
`xsp_OutLen = a3 - xsp_OutBuf`, return 0.

Bounds: before a literal emit it checks `a3 + litlen + 1 >= ceiling`
→ return **-17**, and a run emit when `a3 >= ceiling` → -17.  Because
the ceiling is `OutBuf + InLen`, the encoder refuses whenever output
would reach the input length — incompressible input, and even
zero-length input, fail instead of expanding (see findings/).  Like
1.4 it reads past the input end while scanning (counter is the only
guard).

Parameters via `struct XpkSubParams` (a0), library base a6.
