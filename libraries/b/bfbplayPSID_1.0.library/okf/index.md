# bfbplayPSID.library V1.0

- **Binary:** `binary/bfbplayPSID_1.0.library` (1692B, single CODE hunk 0x600 lw)
- **Identity:** `bfbplayPSID.library V1.0 (26.07.1996)`
- **Purpose:** PSID (C64 SID tune) player — thin tag-driven wrapper
  on `playsid.library` (Hakan Sundell & Ron Birk)
- **RomTag:** RTF_AUTOINIT, ver 1, NT_LIBRARY, pri 0, no `$VER:`
- **InitTable:** dataSize 0xb2 (178), LONG functab, LibInit opens
  `dos.library` (any ver) -> base+40
- **Family:** same bfb player-module template as bfbplayMED!.library
  (done earlier): tag-driven InitModule, 80B session, player lib
  opened lazily at base+48

## Vectors

| LVO | Name | Notes |
|-----|------|-------|
| -6/-12/-18 | Open/Close/Expunge | standard; Expunge closes dos + playsid (plain CloseLibrary — no double-close like MED) |
| -24 | stub | ret 0 |
| -30 | InitModule | TagItem list; loads PSID via filename/handle/memory; opens playsid v1 |
| -36 | EndModule | playsid -66+-36 if player up, frees modbuf(+2)/buf2(+6), CloseLibrary, frees session |
| -42 | PlayModule | gates ExecBase.SoftVer>=36 (-16); playsid -30 lazy init (sess+56 flag, -9), -66 if playing, -54 load(buf,len), -96 vol 50, -60 cursong |
| -48 | StopModule | **arg in A5** (not A0); playsid -72(a0=sess); playing=0, paused=1 |
| -54 | ContModule | playsid -78(a0=sess) when !playing && paused |
| -60/-66 | stubs | ret -1 |
| -72 | SetSubsong | d0=0-based n; clamps to songs-1 (no side effects); stores n+1 1-based at sess+24; if playing: playsid -66 then -60(n+1); returns 0-based index |
| -78 | GetInfo | lazy 16B record {2, 30, &buf[54]=author, &buf[86]=released} via abs-4 execbase |
| -84 | GetDesc | -> "Playsid.library by H\345kan Sundell and Ron Birk." |

## InitModule tags

| tag | meaning |
|-----|---------|
| 0x80000007 | session ptr slot (required; ti_Data=0 -> 80B alloc'd, MEMF_CLEAR) |
| 0x80000001 | filename (dos Open MODE_OLDFILE) |
| 0x80000002 | already-open file handle (not closed after read) |
| 0x80000003 | in-memory image (requires 0x80000008 = length) |

Return codes: 0 ok, -5 playsid missing, -6 open failed, -7 short
read, -8 alloc failed, -9 playsid -30 init failed, -16 SoftVer<36,
-17 missing/malformed tags.

## Session init (havemod)

type=9, fmtname="PSID", name=buf+22 (PSID name field), namelen=30,
songsm1 = buf[15]-1 (byte@21 write + word dec), cursong lo byte =
buf[17] (startSong — doubles as default subsong).
