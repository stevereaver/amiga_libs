# bfbplayMED!.library V1.0

- **Binary:** `binary/bfbplayMED!_1.0.library` (1532B, single CODE hunk 0x158 lw + dead trailer)
- **Identity:** `bfbplayMED!.library V1.0 (28.03.1996)` by Teijo Kinnunen
- **Purpose:** MED / OctaMED module player — thin tag-driven wrapper on `medplayer.library` v2+
- **RomTag:** packed, RTF_AUTOINIT, ver 1, NT_LIBRARY, no `$VER:`
- **InitTable:** dataSize 0xb2 (178), LONG functab, LibInit opens `dos.library` (any ver)
- **Dead trailer:** 31 longs appended past hunk end (file 0x580+), never loaded

## Vectors

| LVO | Name (inferred) | Notes |
|-----|------|-------|
| -30 | InitModule | TagItem list; loads MED/OctaMED module via medplayer |
| -36 | EndModule | stop, free module, close medplayer, free session |
| -42 | PlayModule | lazy medplayer -30 init, then -42 on module buffer |
| -48 | StopModule | medplayer -54; sets stopped flag |
| -54 | ContModule | medplayer -48 when stopped |
| -60 | (stub) | returns -1 |
| -66 | (stub) | returns -1 |
| -72 | SetVolume | clamps to sess+20, medplayer -96, stop/restart around it |
| -78 | (stub) | returns 0 |
| -84 | GetDesc | -> "MED, OctaMED and medplayer.library\nby Teijo Kinnunen" |

## medplayer.library LVOs consumed

-30 (player init, gated by base+156), -36 (player shutdown),
-42 (play module, a0=buffer), -48 (continue, a0=buffer),
-54 (stop), -96 (volume, d0), -102 (load/register module, a0=buffer).

## InitModule tags

| tag | meaning |
|-----|---------|
| 0x80000007 | session block ptr (required; ti_Data=0 -> 80B alloc'd) |
| 0x80000001 | filename (dos Open MODE_OLDFILE) |
| 0x80000002 | already-open file handle |
| 0x80000003 | in-memory module image (requires 0x80000008 = length) |

Return codes: 0 ok, -4 medplayer missing, -6 open failed, -7 short
read, -8 alloc failed, -17 missing/malformed tags.

See `structures/BfbBase.md`, `findings/defects.md`.
