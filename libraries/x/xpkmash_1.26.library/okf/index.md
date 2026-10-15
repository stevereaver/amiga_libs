# xpkMASH.library 1.26 — "Mashiner"

| field | value |
|---|---|
| file | `binary/xpkmash_1.26.library` (2044 bytes, md5 `bb0e29b6edf8cf451bed0e5e6d5ead61`) |
| libname | `xpkMASH.library` |
| idstr | `$VER: xpkMASH.library V1.26` |
| XPK id | `MASH` |
| CPU | 68000 |
| dataSize | 0x4a (Library + exec@34 + seglist@38) |
| RomTag | RTF_AUTOINIT, rt_Version **1**, NT_LIBRARY, pri -127 |
| functab | long offsets relative to lib base, `-1` terminator |
| Plane | AMIGALIBS-93 |

XPK sublibrary implementing "MASH V1.26, good packer"
(WindowSize: 32KB, 2 mixed streams, Dynamic Buffer Allocation).
Same codec as V1.16 (see `../xpkMASH_1.16.library/okf/`): bit-coded
control bytes and raw literal bytes interleave in one output stream —
the bit emitter reserves a byte slot for its accumulator while literal
bytes are copied through the same output pointer.  Bits MSB-first.

Hash-chain match finder: 2-byte hash `((b1<<shift)&0xff00) | b0`,
16-bit position deltas in the chain table (mod-64k positions, aliasing
mod 0x8000), lazy one-step lookahead, next-byte filter heuristic,
`1<<(mode/10)` filter-rejection budget.

V1.26 differs from V1.16 in implementation, not format:
bound `inlen-10` (was -50), only 5 alloc2 sizes (0x20000..0x2000,
shift 8..4), chain table left uninitialized except a single
`chain[in.w] = 0xffff` prime (alloc1 keeps AllocMem garbage!),
and a whole-byte fast path in the bit emitter (rol.l #8 + move.b
writes a field byte raw when >=8 bits remain after a slot store).
Decoder payload loops likewise can swallow whole input bytes.
MaxPkInChunk metadata raised to 0x100000; mode record flags=1,
packspeed 17, unpackspeed 400, ratio 472.

Reconstruction in `source/`:
`xpkMASH.c` (codec + lifecycle), `xpkMASH_lib.s` (RomTag/init/functab/
descriptor/mode-table + a0->stack vector stubs), `endmodule.s`,
`Makefile` (-m68000).  Host harness `work/host.c` round-trips all
compressible inputs; the below-input-window and >64KB-wrap cases are
faithful original defects (nondeterministic on host due to
pointer-low-word addressing).

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
