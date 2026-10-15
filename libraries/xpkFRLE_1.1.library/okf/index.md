---
type: Library
title: xpkFRLE.library 1.1
description: >-
  XPK "Fast Run Length Encoder" chunk packer — an XOR-obfuscated
  ByteRun variant advertising "Cache-optimized RLE": repeat runs
  (n-2)^0x9f + byte, literal runs (len-1)^0x1f + data, no stream
  terminator.
timestamp: 2026-10-10T22:45:00Z
---

# xpkFRLE 1.1

XPK packer sublibrary implementing the XpksSub API (-30 XpksPackerInfo,
-36 XpksPackChunk, -42 XpksPackFree, -48 XpksPackReset,
-54 XpksUnpackChunk, -60 XpksUnpackFree; the free/reset slots and
ExtFunc all point at a `moveq #0,d0` stub).

## Binary facts

- sha256 `73e626253218a9b11251fd64dd98f37b94235a5e461fc75552f67075a42c92c6`, 884 bytes
- single CODE hunk, 0x2f8 bytes; AUTOINIT, absolute-pointer InitTable
- RomTag: ver 1, NT_LIBRARY, pri 0; module entry `moveq #-1,d0; rts`
- name `xpkFRLE.library`, idstring `xpkFRLE v1.1\r\n` — **no $VER: cookie**
- InitTable: dataSize 0x26 (Library + seglist), word-offset functab
  (-1 marker, 10 entries, -1), InitStruct, initFunc stores seglist
- InitStruct: NT_LIBRARY, flags 0x06, version 1, revision 1
- XpkInfo: 'FRLE', flags 9 (PK_CHUNK|UP_CHUNK), chunks 16..131072
  (def 32768), DefMode 16, XpkMode "ByteRun" upto 100, ratio 2%
- framework: textbook Open/Close/Expunge with LIBF_DELEXP in lib_Flags

## Status

Byte-identical.  `make` assembles `source/xpkFRLE_h0.s`
(verbatim asm incl. the raw-emitted noncanonical `c23c`/`923c`
AND.B/SUB.B-with-immediate encodings and the word `6000 0098`
bra), `fixup.py` rewrites the RELOC32 tail to the original
descending order.  md5 `45381000923f1a67ca73aad8526201ff`.
`make cmodel` builds the earlier C reconstruction.
Runtime-verified: `work/oracle.py` (machine68k) logs identical
for original vs rebuild across init, Open/Close, deferred+real
expunge, all dead vectors, XpkInfo island, pack/unpack
round-trips, repeat segmentation (129+129+40), the 128-literal
cap edge, zero-length inputs, and the OutBufLen (-17) overflow.

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [algorithms/](algorithms/index.md)
- [findings/](findings/index.md)
- [log.md](log.md)
