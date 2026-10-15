# iffparse_42.2_BUGGED_.library

"iffparse 42.2 (16.8.93)" — the recalled/bugged WB3.x-era
iffparse.library. 5852B. Flat single CODE hunk (0x59c longs),
AUTOINIT, RELOC32 tail (14 slots ->h0).

- Resident @h0+4 (26B extended); name->h0+0x1e, id->h0+0x2f,
  init->h0+0x4a (InitTable).
- InitTable: dsize 0x30, ftab@h0+0x5a (word-offset table: ffff
  marker + 45 signed-word entries), dtab 0, initfn@h0+0xb8.
- init opens dos.library v37; clipboard.device referenced in code.
