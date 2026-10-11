# xpkSMPL.library 1.0

| field | value |
|-------|-------|
| file | `xpkSMPL_1.0.library` |
| size | 1740 B (1 CODE hunk, 1616 B) |
| init | RTC_AUTOINIT, MakeLibrary(functab=NULL, datasize=0x26) |
| id | `$VER: xpkSMPL.library 1.0 (1.11.93)` |
| kind | xpk sublibrary -- dynamic Huffman + delta pre-coding |
| codec | delta-encoded 8-bit histogram, spliced sorted list + pair merge tree, 4-bit len table (>=15 -> 8-bit `len-31`), MSB-first codes, Huffman trie decoder + 1024-entry 10-bit fast table |
| author | Jorma Oksanen (SMPL family; 1.0/1.1 identical codec with layout change) |
