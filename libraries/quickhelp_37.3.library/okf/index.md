---
type: Library
title: quickhelp.library 37.3
description: >-
  quickhelp.library 37.3 (12.2.99) — text help-viewer library;
  splits help text on newlines, sizes a window via intuition
  TextExtent, opens a taglist window, prints lines; per-open
  session clone of the library data area.
timestamp: 2026-10-15T00:00:00Z
---

# quickhelp.library 37.3

idstring `$VER: quickhelp.library 39.03 ((12.2.99) 19:05:41)` (in
the DATA string hunk).  md5 `c7234b379085496ee76a9d1bc68e9d53`.

## Layout — FOUR hunks

- hunk0 CODE 0x978B: resident + all code.
- hunk1 DATA 16B: AUTOINIT InitTable {dataSize 0x204,
  functab -> hunk3+0, datatab NULL, initfn -> hunk0+0x20}.
- hunk2 DATA 456B: message table ("Too many new line chars",
  "Couldn't open locale.library", intuition/utility/locale.library
  names, catalog name).  initfn checksums the first 0x68 words of
  hunk2+0 (integrity check, constant 0x12da/0x10d9 style).
- hunk3 CODE 76B: 7-entry absolute-long functab + "quickhelp.library"
  + "quickhelp.library 37.3" strings (RomTag Name/IdString point here).

## Vectors (7)

-6 Open (per-open clone of data area: allocs 0x1c8+master@0x36+60,
copies master image from lib-0x2a, checksums, registers deps),
-12 Close, -18 Expunge (Remove+FreeMem, deferred via flags bit3),
-24 stub, -30 main show-help (text split/width measure/window),
-36 window cleanup, -42 getter (returns lib+0x40).

## Status

BYTE-IDENTICAL - verbatim asm `source/quickhelp_h0.s` + `fixup.py`
(split: .data blob -> hunks 1/2/3, original reloc tails spliced);
md5 `c7234b379085496ee76a9d1bc68e9d53`.  machine68k oracle
identical over initfn/open/close/expunge/all vectors + user-vector
text calls.

## Quirks

- Sub at hunk0+0x918 (and its sibling 0x94c) ends with a `beq` that
  lands on the *immediate word* of a `cmpiw` — executes `moveq #0,d0`
  out of the imm bytes.
- Open creates a per-open clone of the library base image and
  self-checksums the copied data (0x10d9-style additive verify).
