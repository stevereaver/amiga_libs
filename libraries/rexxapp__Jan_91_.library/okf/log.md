# log

- Parsed hunk: header says 2 hunks [0x162 longs CODE, 0] ; body
  0x588B + DREL16 x21 (forward order) + empty trailing CODE hunk.
- Fully disassembled; non-AUTOINIT MakeLibrary resident.
- Transcribed to `source/rexxapp.s`; iterated on branch-width and
  shared-tail targets until code body byte-identical.
- `source/fixhdr.py` rewrites GNU ld's 1-hunk header to the
  original's 2-hunk header + trailing empty CODE hunk.
- Result: whole file byte-identical (MD5 1724406df58c813c7db58aef2ff35320).
- machine68k oracle (work/oracle.py): init->MakeLibrary register
  flow, vector layout, open/close/expunge + deferred expunge all
  identical between original and rebuild.
