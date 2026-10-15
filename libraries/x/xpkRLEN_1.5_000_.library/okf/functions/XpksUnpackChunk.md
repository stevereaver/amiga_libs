# XpksUnpackChunk (-54)

PackBits decoder at hunk+0x1d8.  Reads `xsp_InBuf` into a1 and
`xsp_OutBuf` into a0 via `movea.l (a0),a1` / `movea.l 8(a0),a0`
(the params pointer is deliberately discarded — the function never
writes `xsp_OutLen` and never checks `xsp_OutBufLen`).

Dispatch on the token byte in d0:

| token | path |
|------:|------|
| 0x00 | `beq` -> `moveq #0,rts` — always returns 0 |
| 0x01..0x7f | literal: copy `d0` bytes (`subq/bne` loop) |
| 0x80..0xff | `bmi` run: read byte, `neg.b`, emit `-d0` times (`subq/bne` loop) |

Quirk: `neg.b` of -128 yields -128, but the loop condition is `bne`
(not 1.4's `bgt`), so a 0x80 token emits the byte **128** times —
the maximum run — while 1.4 emitted it once.  Round-trip is safe
because the 1.5 encoder never generates 0x80 (runs cap at 124).

Parameters via `struct XpkSubParams` (a0).
