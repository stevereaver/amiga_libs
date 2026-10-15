# streplay 33.8.library — OKF index

## Identity

| field    | value                                                            |
|----------|------------------------------------------------------------------|
| libname  | `streplay.library`                                               |
| version  | 33.8 — `"STReplay.Library V33.8 Kludged 2.10.89 by Olli, dem Größten\r\n"` |
| author   | Olli                                                             |
| size     | 2548 bytes                                                       |
| format   | hunk: CODE(2308 B body) + RELOC32(47 relocs, hunk 0) + END        |
| resident | AUTOINIT (`rt_Flags = 0x81`), 0x30-byte library node            |
| purpose  | SoundTracker/ProTracker module replay engine — drives Paula audio via the VBLANK (INTB_VERTB) interrupt; loads modules from disk through `dos.library` |

## Reconstruction

- **Approach**: pure 68k assembly, byte-identical target (self-modifying
  code — tick counter, speed byte inside a `cmpiw` immediate, module base
  pointer — all live inside the CODE hunk).
- **Source**: `source/streplay_lib.s`, `source/Makefile`, `source/fixup.py`
- **Result**: `streplay.library` is byte-identical to the original
  (MD5 `c810ae6677c04050c5eae2e77141f922`).
- **Runtime**: `work/oracle.py` — lifecycle + all 10 vectors traced
  identically between original and rebuild (LoadModule incl. -2 alloc-fail
  path, Play → AddIntServer, 7 interrupt ticks incl. new-row advance,
  Stop → RemIntServer, deferred expunge).

## Contents

- `structures/layout.md` — hunk layout, RomTag, InitTable, datatab,
  library node, interrupt struct, channel state, globals, period table.
- `functions/vectors.md` — all 10 vectors and every exec/dos LVO call site.
- `findings/quirks.md` — self-modifying code, shared-rts branches,
  encoding quirks.
