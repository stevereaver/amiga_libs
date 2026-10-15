# easylife_1.02.library — work log

- Parsed hunk: 1x CODE 0x28a longs (2600 B), 28 RELOC32 self-relocs.
- RomTag AUTOINIT v1; InitTable@0x64 (dsize 0xfc, ftab@0x74,
  dtab@0xc0, initfn@0xe0). 18 vectors.
- Full 68k disasm; identified dynamic multi-dim array lib by
  Paul Hickman. Transcribed verbatim to source/easylife.s.
- Fixes during diff: idstr missing \r\n (+2B); jump table @0x3f4 has
  12 entries incl. a mid-function entry at 0x40c (movel a0@,d2 shared
  prefix); gas canonicalized cmpl #imm,dn -> cmpi (raw .short 0xb0bc/
  0xb6bc/0xb2bc emitted); several dbf/bras label bindings.
- Result BYTE-IDENTICAL (md5 5d44af290ba9299d96eeb83d53ac11cc).
- machine68k oracle: InitResident, Open x2, -24, -36 hook init,
  -30 hit/miss/early-out, -48 create, -42 free, -54/-60 get/set,
  -66 cmp, -78 build, -84 free, -90 read (+dosfail), -96 write,
  -102 fixup, -108 freetab, -72 freeall, close/deferred-expunge,
  final expunge — identical traces orig vs rebuild.
