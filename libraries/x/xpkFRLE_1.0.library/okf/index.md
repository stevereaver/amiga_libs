---
type: Library
title: xpkFRLE.library 1.0
description: >-
  XPK "Fast Run Length Encoder" chunk packer — an XOR-obfuscated
  ByteRun variant advertising "Cache-optimized RLE.": repeat runs
  (n-2)^0x9f + byte, literal runs (len-1)^0x1f + data, no stream
  terminator.  This is the original 31-Jan-93 implementation that
  the 1.1/1.2 rebuilds rewrote.
timestamp: 2026-10-16T00:00:00Z
---

# xpkFRLE 1.0

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; the free/reset slots and
ExtFunc all point at a `moveq #0,d0` stub).

## Binary facts

- sha256 `5d4f8f16bd935249a88c64afd450c0b8ca9adda960629b00ba9314e13e2e5b4e`, 1124 bytes
- single CODE hunk, 0x3e8 bytes; AUTOINIT InitTable
- RomTag at hunk+4 behind a `moveq #-1,d0; rts` entry stub;
  ver 1, NT_LIBRARY, pri 0, RT_ENDSKIP = hunk end
- name `xpkFRLE.library`; idstring
  `xpkFRLE.library 1.0 (31-Jan-93)\r\n` — RT_IDSTRING points
  *after* a `$VER: ` prefix stored in the preceding bytes
- InitTable: dataSize 0x26 (Library + seglist), word-offset functab
  (-1 marker, 10 entries, -1; offsets relative to the marker word),
  InitStruct, initFunc stores seglist at base+0x22
- InitStruct: NT_LIBRARY, flags 0x06, version 1, **revision 0**
- XpkInfo: 'FRLE', flags 9 (PK_CHUNK|UP_CHUNK), chunks 16..131072
  (def 32768), DefMode 16, XpkMode "ByteRun" upto 100,
  speed 800/1480, ratio 2%
- framework: textbook Open/Close/Expunge with LIBF_DELEXP in lib_Flags

## Codec notes

- Stream format is **identical to FRLE 1.1/1.2**: literal
  `(len-1)^0x1f` + data, repeat `(n-2)^0x9f` + byte.
- Encoder: unrolled `cmpb (a1)+,d0` run counter (15 + 7*16 = 127
  compares after the initial pair -> max run 129, the format max)
  and a four-phase sliding-pair literal scanner with a 32-count
  loop budget whose worst case lands **exactly** on the 128-byte
  literal maximum — the tight design the file's "cache-optimized"
  boast refers to.  The 1.1/1.2 rewrites loosened these bounds
  and introduced corruption defects this version does not have.
- Decoder: computed-goto into unrolled 32-entry store blocks
  (the same trick the 1.2 rebuild reused), and — unlike 1.2 —
  it **does** write `xsp_OutLen`.
- Output bound is `OutBuf + xsp_OutBufLen` (1.2 switched to
  `OutBuf + InLen`).

## Status

FULL — reconstructed C source builds a valid hunk library
(m68k-amigaos-gcc -m68000, two-pass generated functab).
Codec round-trip verified on 40,000 randomized inputs plus
boundary cases (runs/literals at the format maxima).
Latent quirks documented in findings/; no decoder defect.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [algorithms/](algorithms/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
