# BfbBase (dataSize 0xb2 = 178)

| off | field |
|-----|-------|
| +0  | struct Library (34B; OpenCnt @+32) |
| +34 | flags — bit3 delayed expunge |
| +36 | ExecBase |
| +40 | dos.library base |
| +44 | seglist |
| +48 | playsid.library base (opened lazily by InitModule, closed by EndModule/Expunge) |

# BfbSess (80 bytes, MEMF_CLEAR — zeroed, unlike MED's PUBLIC-only)

| off | field |
|-----|-------|
| +0  | UBYTE type = 9 |
| +1  | UBYTE playing |
| +2  | APTR modbuf (offset%4==2 — unaligned LONG access, 68020+ only in original) |
| +6  | APTR buf2 — never written by any function; freed if nonzero |
| +10 | ULONG modlen (unaligned) |
| +14 | ULONG len2 — never written |
| +20 | UWORD songsm1 (songs-1) |
| +24 | UWORD cursong (1-based; init = PSID startSong via byte@25 write) |
| +26 | APTR fmtname = "PSID" |
| +30 | APTR name = modbuf+22 (PSID name field) |
| +34 | ULONG namelen = 30 |
| +38 | APTR info (lazy GetInfo record) |
| +42 | ULONG infosz = 16 |
| +46 | UBYTE paused |
| +56 | ULONG pinit — playsid -30 init done |
