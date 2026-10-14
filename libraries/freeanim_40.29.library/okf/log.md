# freeanim.library 40.29 — RE log

- 188 B, single CODE hunk 27 lw. Parsed RomTag, packed strings,
  InitTable @0x4a (dsize 0x2a), word-mode functab @0x5a
  (4 x 0x000c -> shared stub @0x66), initfn->same stub.
- Relocs: 7 h0->h0 {6,a,12,16,1a,4e,56}; EndSkip at 0xa is a
  relabelled pointer to stub end (0x6a).
- Transcribed to source/freeanim.s; gas byte-packed layout
  reproduced exactly (odd idstr, 1-byte pad). First pass had
  `.short 0` pad (+1 byte shift) and _endskip at stub start;
  fixed to `.byte 0` and endskip->stub end.
- `make` -> byte-identical, md5 d55fa1c912ce38fd8d480cadbcc6ac72.
- No oracle: library contains zero external calls; behavior is
  fully determined by byte-identity + return-0 stub semantics.
