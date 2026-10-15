# muispecial.library 19.11

`muispecial.library` (c)1992-1997 Stefan Stuntz — a MUI support library
whose sole real API spawns a background "MUI-Audio-Process" that plays
an embedded/loaded waveform (`mui:docs/mti.data` or `s:mti.data`)
through `audio.device` channels, driven by `timer.device` delays.

- Version 19.11, 3056 bytes, MD5 `e0bfd6a721a26f143b834b8dd041fcd9`
- Two hunks: HUNK_CODE 2800B + HUNK_DATA 88B (near-data globals)
- **Non-AUTOINIT** resident: `rt_Init` points at a hand-written
  initialiser that calls `exec.MakeLibrary` itself
- Descending RELOC32 groups (14 h0-refs, 9 h1-refs)
- Deps opened lazily on first Open: dos.library, graphics.library,
  utility.library (all v37)

## Layout (hunk0)

| off | content |
|-----|---------|
| 0x000 | `moveq #0,d0; rts` — the reserved -24 vector target |
| 0x004 | `muispecial.library\0` (lib name) |
| 0x017 | `$VER: muispecial.library 19.11 (12.02.97) ©1992-1997 Stefan Stuntz\r\n\0` |
| 0x05c | RomTag (flags=0 → non-autoinit, ver 19, type NT_LIBRARY) |
| 0x076 | string table: dos/graphics/utility/timer/audio names, `mui:docs/mti.data`, `s:mti.data`, `s:`, `MUI-Audio-Process` |
| 0x0f4 | initfn (direct init: MakeLibrary + field setup) |
| 0x988 | functab: 8 longs + `ffffffff` |
| 0x9ac | tail helpers: ioreq alloc/free, BeginIO thunk, 32÷32 div |

## Data hunk (gd, a4-relative via `lea.l $0.l`)

| off | field |
|-----|-------|
| +0x00 | ExecBase |
| +0x04 | UtilityBase |
| +0x08 | DOSBase |
| +0x0c | GfxBase |
| +0x10 | MUI-Audio-Process task ptr (0 = not running) |
| +0x14 | loaded mti.data buffer (AllocVec'd) |
| +0x18 | 8-byte waveform table `01 08 09 02 04 06 00 00` |
| +0x1e | busy word (set on launch failure) |
| +0x20 | SignalSemaphore (36B) |
| +0x4e,+0x52 | mti.data header longs (validated == 0x10f3a, 0x2596) |

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
