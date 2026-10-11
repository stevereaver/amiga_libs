# descriptor (hunk 0x43a)

## XpkInfo
| field | value |
|-------|-------|
| XpkInfoVersion / LibVersion / MasterVersion / ModesVersion | 1/1/2/0 |
| xi_Name | "SpeedLZ" |
| xi_LongName | "Speed Lempel-Ziv77 for graphics data and fast decompress" |
| xi_Description | "Based upon a workshop of Adisak Pochanayon 1993, all rights reserved" |
| xi_ID | 'SLZ3' |
| xi_Flags | 0x8009 |
| xi_MaxPkInChunk | 0x7fffffff |
| xi_MinPkInChunk | 15 |
| xi_DefPkInChunk | 0x7fff |
| xi_PackMsg / UnpackMsg | "Lempel-Ziving" / "Unlempel-Ziving" |
| xi_PackedMsg / UnpackedMsg | "Lempel-Zived" / "Unlempel-Zived" |
| xi_DefMode | 100 |

## XpkMode (hunk 0x552)
| field | value |
|-------|-------|
| xm_Next | 0 |
| xm_Upto | 100 |
| xm_Flags | 1 |
| xm_PackMemory | 1 |
| xm_UnpackMemory | 1 |
| xm_PackSpeed | 30 |
| xm_UnpackSpeed | 600 |
| xm_Ratio | 100 |
| xm_ChunkSize | 0 |
| name | "SpeedLZ" |
