# mathieeedoubbas 31.3 (WB1.1) — OKF index

## Identity

| field    | value                                                        |
|----------|--------------------------------------------------------------|
| libname  | `mathieeedoubbas.library`                                    |
| version  | 31.3 — `"mathieeedoubbas 31.3 (23 Nov 1985)\r\n"`            |
| source   | Commodore Kickstart/Workbench 1.1 IEEE double-precision math |
| size     | 2512 bytes                                                   |
| format   | hunk: 5 entries — CODE(324) + CODE(660) + CODE(1172) + empty CODE + empty DATA, RELOC32 + END |
| resident | AUTOINIT (`rt_Flags` = 0x81), RomTag at hunk0+0x08, `rt_EndSkip` = 0x144 |
| purpose  | base IEEE-double library: fix/flt/cmp/tst/abs/neg/add/sub/mul/div |

## Reconstruction

- **Approach**: pure 68k assembly, byte-identical target. Three source files,
  one per populated hunk, plus a generated linker script forcing one output
  hunk per object and a post-link fixup for the two empty trailer hunks and
  the original (non-sorted) RELOC32 group order.
- **Source**: `source/h0.s`, `source/h1.s`, `source/h2.s`, `source/Makefile`,
  `source/fixup.py`
- **Result**: `mathieeedoubbas.library` is byte-identical to the original
  (MD5 `02b255ba151f46c732ea7f1a83959047`).
- **Runtime**: `work/oracle.py` — lifecycle + all 10 vectors traced
  identically on original and rebuild under machine68k.

## Hunk map

| hunk | size  | contents                                                        |
|------|-------|-----------------------------------------------------------------|
| 0    | 324   | RomTag, strings, InitTable, datatab, functab (14 longs), lifecycle (initfn/Open/Close/Expunge) |
| 1    | 660   | IEEEDPFix/IEEEDPFlt/IEEEDPAbs bodies, 6 core-call stubs (inline selector word after jsr), 3 arg marshalling wrappers, 10 vector entry stubs, 3 self-modifying scratch cells (in CODE!) |
| 2    | 1172  | IEEE-double arithmetic core: dispatcher + add/sub/mul/div/neg/cmp/tst |
| 3    | 0     | empty CODE hunk (declared, no body)                              |
| 4    | 0     | empty DATA hunk (declared, no body)                              |

## Contents

- `structures/layout.md` — hunk/romtag/inittable/datatab/functab details,
  scratch cells, dispatcher protocol.
- `functions/vectors.md` — all 10 public vectors + calling conventions.
- `findings/quirks.md` — self-modifying code, overflow/edge-case behaviour,
  dead code tail, relocation order.
- `log.md` — work log.
