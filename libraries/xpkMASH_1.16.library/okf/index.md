# xpkMASH.library 1.16 — "Mashiner"

| field | value |
|---|---|
| file | `binary/xpkMASH_1.16.library` (2036 bytes, md5 `2159cd7aadade043a1aff6d918b0f1e4`) |
| libname | `xpkMASH.library` |
| idstr | `$VER: xpkMASH.library V1.16` |
| XPK id | `MASH` |
| CPU | 68000 |
| dataSize | 0x4a (Library + exec@34 + seglist@38) |
| RomTag | RTF_AUTOINIT, rt_Version **1**, NT_LIBRARY, pri -127 |
| functab | long offsets relative to lib base, `-1` terminator |
| Plane | AMIGALIBS-91 |

XPK sublibrary implementing "MASH V1.16, another LZ77-family"
(WindowSize: 32KB, 2 mixed streams, Dynamic Buffer Allocation, Nice CF).
The "2 mixed streams" are bit-coded control bytes and raw literal bytes
interleaved in one output stream: the bit emitter reserves a byte slot
for its accumulator while literal bytes are copied through the same
output pointer. Bits are MSB-first.

Hash-chain match finder: 2-byte hash `(b1<<shift|b0)&0xff00|b0` where
`shift` scales with the second (dynamically-sized) work allocation,
16-bit position deltas in the chain table (mod-64k positions, aliasing
mod 0x8000), lazy one-step lookahead, and a "next-byte filter" that
only evaluates candidates whose byte at the current best length equals
the byte that ended the previous best match.  `1<<(mode/10)` bounds the
number of filter *rejections* per position.

The V1.16 packer has a real corruption defect: len-2 matches whose
distance is >= 512 emit a token whose `00` selector prefix is polluted
by the high distance bits, and the stream then desyncs/decodes wrong.
V1.98 ("good packer") is the successor.

Reconstruction in `source/`:
`xpkMASH.c` (codec + lifecycle), `xpkMASH_lib.s` (RomTag/init/functab/
descriptor/mode-table + a0->stack vector stubs), `endmodule.s`,
`Makefile` (-m68000).  Host harness `work/host.c` round-trips all
compressible inputs; corrupt cases reproduce the original defect
bit-exact (verified against an instruction-level model of the original
decoder).

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
