# descriptor (hunk ~0x3fa)

## XpkInfo
| field | value |
|-------|-------|
| xi_XpkInfoVersion / LibVersion / MasterVersion / ModesVersion | 1/4/2/0 |
| xi_Name | "LZ-Speeder" |
| xi_LongName | "LZ-Welsh (not Welch) 020+ V4.3" |
| xi_Description | "LZW3 like, better compression" |
| xi_ID | 'LZW4' (0x4c5a5734) |
| xi_Flags | 0x8009 |
| xi_MaxPkInChunk | 0x7fffffff |
| xi_MinPkInChunk | 0 |
| xi_DefPkInChunk | 0x50000 (327680) |
| xi_PackMsg / UnpackMsg | "Annihilate" / "Reanimate" |
| xi_PackedMsg / UnpackedMsg | "Oh god, It is done!" / "Hehe, fast hew." |
| xi_DefMode | 50 ("ashes") |

## XpkMode chain (4 records, 32 B each + name)

| xm_Upto | name | xm_Flags | xm_PackMemory | xm_UnpackMemory | xm_PackSpeed | xm_UnpackSpeed | xm_Ratio | xm_ChunkSize |
|---------|------|----------|---------------|-----------------|--------------|----------------|----------|--------------|
| 25 | "cremation" | 1 | 0x80004 | 0 | 18 | 560 | 324 | 0 |
| 50 | "ashes" | 1 | 0x80004 | 0 | 8 | 560 | 347 | 0 |
| 75 | "grave" | 1 | 0x80004 | 0 | 6 | 560 | 353 | 0 |
| 100 | "oblivion" | 1 | 0x80004 | 0 | 4 | 560 | 355 | 0 |

xm_Upto selects the lazy-match budget the encoder derives as
`(xsp_Mode-1)/25`: 25->0 (greedy), 50->1, 75->2, 100->3.
xm_PackMemory truthfully reports the 0x80004-byte workmem.
