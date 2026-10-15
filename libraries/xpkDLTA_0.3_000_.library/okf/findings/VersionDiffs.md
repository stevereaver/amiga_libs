---
type: Finding
title: Differences vs xpkDLTA 0.2
---

# 0.3(000) vs 0.2

Same skeleton and the same delta codec idea, but a substantial rework:

| area | 0.2 | 0.3(000) |
|------|-----|----------|
| dataSize | 0xfc (descriptors embedded in base) | 0x26 (descriptors are code islands) |
| XpkInfo | built in base+0x26 by InitStruct | static island at code+0x15a |
| xi_Flags | 0x2000 (ENCRYPTION only) | 0x2009 (+PK_CHUNK\|UP_CHUNK) |
| xi_MinPkInChunk | 1 | 0 |
| xi_Name / LongName | "DLTA" / "DELTA v0.2" | "Delta" / "Delta Encryptor V0.3" |
| mode desc | "ByteMode" (in base, flags 0, speeds 0) | "bytemode" (flags 1, speeds 531/743) |
| id string | `xpkDLTA.library v0.2` (no $VER) | `$VER: xpkDLTA V0.3 (1 Oct 2013)...` |
| bounds checks | -10/-11 present | removed — always returns 0 |
| xsp_Sub[0]/[1] carry | present | removed |
| OutLen on unpack | written | **not written** (regression) |
| loop counter | `subq.w`/`bcc` — off-by-one, processes InLen+1 bytes | `subq.l`/`bne` — exact InLen |
| reloc tail order | descending | ascending |
| rt_EndSkip | points at trailing `nop` | literal 0 |
| expunge | stack-juggles a0/a1/a6 | movem d2/a5-a6 (like xpkNONE) |

The 0.3 codec drops chunk chaining entirely; each chunk is
self-contained (`out[0] = in[0]`, `out[i] = in[i] - in[i-1]`).
