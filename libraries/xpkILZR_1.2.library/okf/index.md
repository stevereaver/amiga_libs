---
type: Library
title: xpkILZR.library 1.2 "Incremental LZ-Renau"
description: >-
  Jose Renau XPK sublibrary (Feb 19 1994) -- hash-chain LZSS
  with an MSB-first bit stream and ABSOLUTE-position match
  tokens.  Earlier build than the 1.5 sibling and materially
  different: AUTOINIT + manual init, per-Open PRIVATE COPIES
  of the whole library (descriptor block included), a pool
  sub-allocator hanging off base+0x110, and a runcap
  tail-budget that bounds the tail match clamp.  Two workmem
  blocks (head 0x10000 + chain 0x8024) via the sub-allocator;
  PackFree leaks both (drops pointers only).
timestamp: 2026-10-28T00:00:00Z
---

# xpkILZR.library 1.2

"Incremental LZ-Renau" XPK sublibrary — fast hash-chain LZSS.
Stream: `<inlen:u16>{token}*`, MSB-first bits;
`1`+8-bit literal, `0`+pos(w)+len-3(4).  `pos` is an
ABSOLUTE input/output index (decode copies `len` bytes from
`out[pos]`); `w` starts at 8 and grows as the cursor crosses
powers of two (pack: input cursor; unpack: output cursor).

## Binary facts

- 2088 bytes, single CODE hunk, `HUNK_RELOC32` × 14
- RomTag at code+4, `RTF_AUTOINIT`, ver 1, `NT_LIBRARY`
- entry stub `moveq #0,d0; rts` at code+0 (also the -24
  vector via a BACKWARD offset `-0x2e`)
- InitTable at code+0x1e: dataSize `0x114`, word-offset
  functab (10 vectors), `datatab = NULL` (InitStruct clears),
  initRoutine = manual init at code+0x1b2
- LibInit copies a 192-byte block (code+0xea..0x1a9) into
  base+0x3c: `$VER:` string (with the shipped "xpkIZLR"
  typo), XpkMode record, XpkInfo, then 0x1000 minsize tail
- private base fields: +0x22 seglist, +0x2e dead fixup list,
  +0x32 master self/back pointer, +0x36 = 0x3c copy bias,
  +0xf8 suballoc minsize (0x1000), +0x108 ioerr, +0x10c
  memflags, +0x110 freelist head
- idstring `xpkILZR v1.3` (file version 1.2; the block's
  `$VER:` says "xpkIZLR.library 1.2" — transposed letters)
- lib_Version/lib_Revision = 1.2 (base+0x14/0x16)

## Vectors (offsets relative to functab base)

| LVO | off | Function |
|-----|-----|----------|
| -6  | 0x01d8 | LibOpen — clone-per-open |
| -12 | 0x0270 | LibClose — frees copy, dec master |
| -18 | 0x02d2 | LibExpunge — resolves master |
| -24 | 0xffd2 | entry stub ret0 (backward) |
| -30 | 0x0328 | XpksPackerInfo → base+0x9e |
| -36 | 0x0330 | XpksPackChunk |
| -42 | 0x0618 | XpksPackFree — drops ptrs, LEAKS |
| -48 | 0x0622 | XpksPackReset — clears head only |
| -54 | 0x0640 | XpksUnpackChunk |
| -60 | 0x0632 | bare `rts` (d0 undefined) |

## Contents

- [functions](functions/index.md) — vectors & framework
- [structures](structures/index.md) — base, params, descriptors
- [algorithms](algorithms/index.md) — stream format, hash
  chains, pool sub-allocator
- [findings](findings/index.md) — quirks & shipped defects
- [log](log.md) — reverse-engineering log
