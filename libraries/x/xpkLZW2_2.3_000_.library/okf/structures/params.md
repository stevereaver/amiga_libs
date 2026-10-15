# Structures

## XpkSubParams (codec argument block, via a0)

| off | field |
|-----|-------|
| 0x00 | xsp_InBuf |
| 0x04 | xsp_InLen |
| 0x08 | xsp_OutBuf |
| 0x0c | xsp_OutBufLen (ignored by the encoder) |
| 0x10 | xsp_OutLen (written only on success, by pack) |
| 0x14 | xsp_Flags |
| 0x18 | xsp_Number |
| 0x1c | xsp_Mode |
| 0x20 | xsp_Password |
| 0x24 | xsp_LibVersion |
| 0x28 | xsp_Tags[3] |
| 0x34 | xsp_Sub[4] -- [0] = workmem base + 4 |

## Workmem layout (xsp_Sub[0], alloc 0x50004 = 327,684)

| range | use |
|-------|-----|
| sub-4 | AllocMem size word (written by PackChunk, read by PackFree) |
| sub+0x00000 | hash[16384] -- 4-byte head pointers, keyed by (w(p)^w(p+2))&0x3fff |
| sub+0x10000 | chain[65536] -- 4-byte links indexed by pointer low 16 bits |

The chain ring is a modulo-64K window over the pointer's
low address bits -- the same 64 KB "big window" the
description advertises.  It is NEVER initialised
(see findings).

## Static descriptor (hunk+0x3aa)

XpkInfo (60 bytes) at 0x3aa, XpkMode (42 bytes incl. the
inline 10-byte description) at 0x402, strings to 0x543.

| field | value |
|-------|-------|
| xi_XpkInfoVersion/LibVersion/MasterVersion/ModesVersion | 1/2/2/0 |
| xi_Name | "LZ-Speeder" |
| xi_LongName | "LZ-Welsh (not Welch) V2.3" |
| xi_Description | "LZSS with big window (64 KB), slow packing and fast decrunch" |
| xi_ID | 'LZW2' |
| xi_Flags | 9 (XPKIF_CHUNK|XPKIF_UPASS? = PK_CHUNK|UP_CHUNK) |
| xi_MaxPkInChunk / xi_DefPkInChunk | 0x7fffffff / 0x50000 |
| xi_PackMsg / xi_UnpackMsg / xi_PackedMsg / xi_UnpackedMsg | Annihilate / Reanimate / Oh god, It is done! / Hehe, fast hew. |
| xi_DefMode | 100 |
| xm_Next / xm_Upto | 0 / 100 |
| xm_Flags | 1 (XPKMF_A3000SPEED) |
| xm_PackMemory / xm_UnpackMemory | 0x50004 / 0 |
| xm_PackSpeed / xm_UnpackSpeed | 32 / 556 |
| xm_Ratio / xm_ChunkSize | 323 / 0 |
| xm_Description | "cremation" (inline, referenced!) |
