# mhimpegit.library 1.1 — work log

1. Parsed hunk file: 2 hunks (CODE 2728 B + DATA 4 B body / 16 B alloc),
   DREL16 `0x3f7` relocs (39 -> h0, 67 -> h1 fields).
2. Located RomTag @0x2c4 (AUTOINIT) and InitTable @0x344; 14 vectors;
   initfn @0x134 with dep-open helper @0x04 (dos+intuition v37,
   Alert on failure).
3. Capstone-driven generator (`work/genasm.py`) emitted `mhimpegit_h0.s`
   verbatim with branch-label substitution and symbolic `_gd+N` /
   self-hunk references at all 106 relocated fields; data islands
   (strings, RomTag, function table, datatab, InitTable) emitted as
   raw data between code regions.
4. Fixed gas canonicalizations with raw `.short`/`.long` emits:
   `c03c` and.b, `90bc` sub.l, `b2bc` cmp.l d1, `b27c` cmpa.l a1 —
   13 sites. hunk0 body byte-identical.
5. `fixup.py` rewrites GNU `0x3ec` RELOC32 tail into the original
   `0x3f7` DREL16 layout (original offset ordering hardcoded), emits
   hunk1 as 4 B DATA body. Result BYTE-IDENTICAL,
   MD5 `9857940b35d4b8e1b899a5a42469eed2`.
6. Vector analysis: MHI-style decoder API — AllocDecoder /
   FreeDecoder / QueueBuffer / GetBufferHandle / status / Play /
   Stop+ClearBuffer / Pause stub / Query / SetParam, fronting
   prelude.library; ctx in a3 (nonstandard ABI).
7. `work/oracle.py`: machine68k with fake exec/dos/intuition/prelude
   (real MinList AddTail/RemHead, prelude 5.6 + MPEGit bit + hw flag).
   Exercised init, lifecycle, alloc ok + badver + nomod, queue,
   notify, status, play, getbuf, all Query selectors, all SetParam
   commands, stop/drain, free, deferred-less expunge:
   **RUNTIME-IDENTICAL**.
8. Defect recorded: AllocDecoder failure paths leak an OpenLibrary of
   prelude.library (see findings/quirks.md).
