# xpkLZBS.library 2.1 (000) — "LZStreamer"

| field | value |
|---|---|
| file | `binary/xpkLZBS_2.1(000).library` (2036 bytes, md5 `d6984dda7cb293ce6c373c71d15cad58`) |
| libname | `xpkLZBS.library` |
| idstr | `$VER: xpkLZBS V2.1 (1 Oct 2013) by Niels Froehling` |
| XPK id | `LZBS` |
| CPU | 68000 (no AttnFlags gate in LibInit) |
| dataSize | 0x26 (Library + seglist @34) |
| RomTag | RTF_AUTOINIT, rt_Version **2**, NT_LIBRARY |
| functab | word offsets, leading `ffff` marker, `-1` terminator; offsets relative to the marker word itself |
| Plane | AMIGALIBS-90 |

XPK sublibrary implementing an LZSS variant branded "BSI Bitstream
Packer". Packer uses a 65536-entry head table plus a `1<<bits` ring of
chain links over 3-byte hash keys; literals run of 21+ bytes switch to
a compact run escape. Decoder needs no work memory.

Reconstruction in `source/`:
`xpkLZBS.c` (all logic), `xpkLZBS_lib.s` (RomTag/init/descriptor/
mode-table glue + LibInit), `genfunctab.py` (two-pass functab),
`functab_stub.s`, `Makefile` (-m68000).

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
