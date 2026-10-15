---
type: Finding
title: Absolute-long function table
description: boards.library stores absolute 32-bit vector addresses, unlike the word-offset tables of iffparse/freeanim/_asl.
timestamp: 2026-10-10T18:00:00Z
---

# Absolute-long function table

The InitTable funcTable pointer leads to five `dc.l` absolute
addresses plus a `dc.l -1` terminator — the other supported
AUTOINIT table format (exec's MakeLibrary accepts both word-offset
and absolute-long tables).  Reconstruction therefore uses a
hand-written `functab.s` with `.long` entries; REL32 relocations
fix the addresses at load time.  (Same format in fantasia and
fwfiltertype.)
