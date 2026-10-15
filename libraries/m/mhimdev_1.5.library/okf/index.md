# mhimdev 1.5.library — OKF index

## Identity

| field    | value                                                        |
|----------|--------------------------------------------------------------|
| libname  | `mhimdev.library`                                            |
| version  | 1.5 — `"mhimdev.library 1.5 (04.03.2023)"`                    |
| author   | Michael Henke                                                |
| size     | 2608 bytes                                                   |
| format   | hunk: CODE(2412 B body) + RELOC32(36 relocs, hunk 0) + END    |
| resident | AUTOINIT (`rt_Flags = 0x80`), 0x2a-byte library node          |
| purpose  | MHI (Music Hardware Interface) driver library wrapping `mpeg.device` — streams MPEG audio buffers via `CMD_WRITE`, with volume/balance control, pause, and an async buffer-recycling scheme (softint-driven done list) |

## Reconstruction

- **Approach**: pure 68k assembly, byte-identical target (vbcc-style
  compiled C; `linkw` frames, register args a0/d0/d1/a3, stack args for
  helpers, `__mulsi`/`__udivmod` runtime routines at the hunk tail).
- **Source**: `source/mhimdev.s`, `source/Makefile`, `source/fixup.py`
- **Result**: `mhimdev.library` is byte-identical to the original
  (MD5 `9fb62cb3abdf99e13433a74e0ea34712`).
- **Runtime**: `work/oracle.py` — lifecycle + all 14 vectors traced
  identically between original and rebuild (env-var device override via
  `MHIMDEV`/`DEVICE,UNIT/N` ReadArgs, softint reply handler, buffer pool,
  query strings, volume command construction, deferred expunge, alloc-fail
  and no-dos paths).

## Contents

- `structures/layout.md` — hunk layout, RomTag, InitTable, datatab,
  driver-handle structure, embedded Interrupt/MsgPort wiring
- `functions/vectors.md`  — all 14 vectors, helpers, exec/dos call map
- `findings/quirks.md`    — oddities (UNIT arg reads `str[3]`, CopyMem 255,
  query classifier, state machine)
- `log.md`                — chronological reconstruction notes
