# xpkZENO 1.1 — RE log

## Identification

- 2260-byte single-hunk binary, MD5-distinct from ZENO 1.2.
  AUTOINIT RomTag (EndSkip 0x85a), InitTable at 0x22:
  dataSize 0x44, word-offset functab at 0x36, datatab = 0,
  initfn 0x1ba.
- idstring `xpkZENO 1.1\r\n`, libname `xpkZENO.library`,
  description `LZ78 12-14bit`.  Earlier Tuenkler-generation
  ZENO; structurally related to the 1.2 rebuild but with a
  different workmem map, header padding, decoder reader and
  free routine.

## Decode

- All 10 vectors resolved: -24/-48 land on the hunk+0
  `moveq #0,d0; rts` entry stub; -42 and -60 are TWO DIFFERENT
  free routines (unlike 1.2 which shares one).
- LibInit does manual field init (datatab = 0): type 9, name,
  flags 6, ver/rev 1.1, idstr, seglist@34, clones a 20-byte
  InitTable image to lib+48 and runs a fixup list whose count
  field is 0 (dead).
- Packer gate: `InLen < 128` (signed) -> -17; the constant is
  read pc-relative out of the descriptor's xi_MinPkInChunk
  field (0x80) at hunk+0x182.
- Packer init: signed mode-byte clamp 1..99, bits =
  (mode-1)/33+12 via `divsw`; D3 = (1<<bits)+0x800; workmem
  AllocMem(7*D3+8, MEMF_CLEAR).  On AllocMem failure the mode
  byte is rewritten (>=67 -> 50, 34..66 -> 0) and retried —
  but the retry uses the PRE-WRITE byte, so the first retry
  allocates the same size again before the downgrade takes
  effect; mode < 34 -> -7.  An identical orphan fallback block
  at 0x5bc is unreachable dead code.
- Header: u32 hash, u8 bits, u8 namelen where
  namelen = 3-((out+5)&3) so the code stream lands
  long-aligned; the pad bytes are SKIPPED, never written
  (stale outbuf content passes through).
- Decoder uses a signed-BYTE bit counter (d6) against
  long-aligned reads; stream data always lands at offset 0
  mod 4 because the packer aligns it.  The data&3==3 path
  loses the first code's low bit (dead read of the next
  long's top bit) — unreachable for packer-produced streams.
- Mode records at 0xbc/0xe4/0x10e/0x138: chain runs
  desc->0x138 ("12 bit") -> 0x10e ("13 bit") -> 0xe4
  ("14 bit") -> NULL.  The "15 bit" record at 0xbc is the old
  30-byte format (no xm_ChunkSize pad word) and nothing links
  to it — leftover dead data.

## Oracle verification (machine68k)

- Rebuilt library loads: 10 vectors, descriptor, posSize 102,
  rev=1 — identical to original header fields.
- 16-input corpus: pack rc/outlen identical; all produced
  streams BYTE-IDENTICAL to the original's.
- Modes 0/1/33/34/50/66/67/99/100/200 on rep4k-style data:
  bits 12/13/14 selected identically, streams byte-identical.
- Password streams: hash 0x77767ae4 for "secretpw" identical;
  wrong-password unpack identical (password checked only on
  first call, while Sub[0]==0).
- InLen 127 -> -17 with no alloc; 128/129 proceed then hit the
  output budget -> -17 (incompressible inputs).
- PackFree frees 7*D3+8 (71688 at 13-bit); UnpackFree frees
  4*Tsize+4 (32772 at 13-bit) — 4 bytes short of the
  4*Tsize+8 alloc (shipped defect, preserved).
- Unwind-stack-in-output scenario (xsp_OutBufLen = produced
  length): BOTH binaries corrupt the last 3 output bytes
  identically — the earlier-suspected "rnd1k tail defect" is
  this stack-overlap artifact, not a codec desync.  With the
  stack outside the output span all inputs round-trip,
  including rnd1k.
