# ppipc_2.2.library — reconstruction log

- Parsed hunk file: 11 hunks — CODE 0xb0, DATA 0x38, DATA 0xa0,
  CODE 0xe8, DATA 0x04, CODE 0x3c0, BSS 0x10, CODE 0x134, DATA 0x10,
  CODE 0x84, CODE 0x28. RELOC32 records in the original linker's
  descending-by-target order.
- RomTag at h0+4 after a `moveq #20,d0; rts` stub; AUTOINIT; rt_Init
  reloc→h2+0x8a = InitTable `[dsize=0x22][functab→h2+0x2e]
  [datatab→h1+0][initfn→h3+0]`.
- datatab (h1) uses only the extended 24-bit-offset commands
  (0xe0/0xd0/0xc0 + offset word), entries word-aligned; decodes to
  ln_Type=9, ln_Name→name, ln_Flags=6, ver=1, rev=0, id→idstr.
- initfn additionally stores a6→h1+0x32 (SysBase cell used by h10
  wrappers), a0→h4 (seglist cell), copies h2+0x2a/0x2c ver/rev into the
  lib (so it reads 2.2), NewLists the h6 port list.
- functab: 22 absolute-long entries: -6..-24→h3, -30..-90→h5,
  -96→h7, -102/-108→h9, -114..-132→h3 null.
- Transcribed every hunk to GAS asm. Original is compiled C: stack args
  in the helper trio and _mkport, register args in the real vectors.
- Encoding traps hit along the way:
  - `2148 0008` reads `movel a0,a0@(8)` — the NewList TailPred store is
    on a0, not a1 (mis-decoded twice during review).
  - Cross-hunk calls are `jmp abs.l` stubs at hunk tails; h5 relocs to
    h0 at 0x3ba/0x3b4/0x3ae (descending), h7 relocs at 0x118→0xfa.
  - h6 BSS is exactly 4 longs (16B), not a full MinList+pad.
- GNU ld emitted sorted reloc offsets; fixup.py rewrites each hunk's
  RELOC32 groups in the original order (h0: →h0 2, →h2 3; h1: →h2 2;
  h2: →h1,→h2,→h3,→h5,→h7,→h9; h3: →h0,→h1,→h2,→h4,→h6; h5: →h0 3,
  →h6 3; h7: →h5 8,→h8 1,→h10 2; h10: →h1 2).
- Result: byte-identical, md5 22686832f5b26d0c8d0c57e3746c5c5c.
- machine68k oracle (work/oracle.py): emulates MakeLibrary + InitStruct
  with the extended datatab commands, real AddHead/Remove/FindName list
  semantics on the h6 port list, and exercises open×2, every vector
  -30..-108 plus stubs -114..-132, deferred expunge (flags 06→0e),
  broker flow with and without PortBrokerPort, port drain to empty
  list, and the real expunge Remove(lib)+FreeMem(lib-132,200) path.
  Traces identical between original and rebuild.
