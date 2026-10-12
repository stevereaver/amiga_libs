# xpkRDCN 2.4 — RE Log

## Session

1. Identified binary: `xpkRDCN_2.4(000).library`, code hunk 0x6f0,
   AUTOINIT, compact word-offset functab @0x94, dataSize 0x26.
   Sibling of xpkZENO/xpkFAST (Niklas Sjöberg XPK sublibs, 2013).
   Name is `xpkRDCN.library` — NOT `dxpkRDCN.library`; the 'd' is the
   low byte of rt_Init=0x64.

2. Mapped all 10 vectors (-6..-60) via the sibling skeleton; decoded
   dispatcher (AllocMem 0x4004/0x48004, mode<=79 speedy / >=80
   crawling, BCC unsigned compare), PackFree (size-prefixed alloc),
   PackReset (movem pre-decrement sweep, hash only).

3. Decoded bitstream: 16-item BE ctrl words; tokens MATCH2B/MATCH3B
   (12-bit dist+3), RLE2B/RLE3B (run len+3 / +19, caps 18/4114).

4. Decoded both packers:
   - speedy: 4096-long 3-byte hash, single candidate, dist<=0x1002,
     len cap 0x10f, RLE cap 0x1012, limit out+outcap-48.
   - crawling: 64K-long hash + 8K chain (indexed by ADDRESS&0x1fff),
     lazy per-token position insertion (prevLen inserts), chain walk
     with best-byte skip pre-check, dist 3..0x1002, RLE wins ties,
     limit out+inlen.

5. Reconstruction: `xpkRDCN.c` (lifecycle + both packers + decoder),
   `xpkRDCN_lib.s` (RomTag/datatab/descriptor verbatim), generated
   two-pass functab, endmodule tail `72 00 00 08`.

6. Verification:
   - Header + descriptor byte-identical modulo relocations.
   - Initial host test failed: speedy streams 1 byte short.
     Root cause: original's `subq #1,a1` after the match/RLE compare
     loops is UNCONDITIONAL — the overlap-exit path also needs the
     decrement (a1 overshoots one byte past a match ending at
     source==cur). Fixed both loops; streams now byte-exact.
   - Speedy: byte-exact vs independent Python model (8 streams).
   - Crawler: byte-exact vs independent model (10 streams).
   - Decoder: independent Python decoder validates all streams;
     trailing-garbage tail writes confirmed faithful.
   - Defects catalogued: dist 1..2 underflow (speedy), chain
     address-aliasing, stale chain links, OOB reads, hash sign quirk.
