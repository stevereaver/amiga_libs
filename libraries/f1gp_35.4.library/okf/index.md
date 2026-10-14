# f1gp 35.4.library — OKF index

## Identity

| field    | value                                            |
|----------|--------------------------------------------------|
| libname  | `f1gp.library`                                   |
| version  | 35.4 — `"f1gp 35.4 (22.8.97)\r\n"`               |
| author   | Oliver Roberts — `"Copyright (c) 1995-1997 by Oliver Roberts"` |
| size     | 2516 bytes                                       |
| format   | hunk: CODE(2216 B) + DATA(104 B body / 196 B declared alloc) + RELOC32 + END |
| resident | non-AUTOINIT (`rt_Flags` has no RTF_AUTOINIT)    |
| purpose  | runtime patcher for F1GP (Formula One Grand Prix) — hooks a running F1GP process for telemetry/editing tools |

## Reconstruction

- **Approach**: pure 68k assembly, byte-identical target (hand-written original,
  unusual encodings the original assembler emitted literally).
- **Source**: `source/f1gp_lib.s`, `source/Makefile`, `source/fixup.py`
- **Result**: `f1gp.library` is byte-identical to the original
  (MD5 `69c0f71d33e8a60891b2c0824986b028`).
- **Runtime**: `work/oracle.py` — lifecycle/vector trace identical
  between original and rebuild.

## Contents

- `structures/layout.md` — hunk layout, RomTag, InitTable, data-hunk globals,
  patch-node struct, library node.
- `functions/vectors.md` — all 8 vectors and every exec LVO call site.
- `findings/quirks.md` — protection checks, magic values, encoding quirks.
- `log.md` — work log.
