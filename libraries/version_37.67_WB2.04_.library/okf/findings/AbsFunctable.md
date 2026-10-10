---
type: Finding
title: Absolute-long function table
description: Function table uses absolute pointers, not word offsets.
timestamp: 2026-10-10T19:00:00Z
---

# Absolute-long function table

Unlike the later iffparse.library exemplar (word offsets relative to
the table start, led by a -1 marker word), this library's function
table is four absolute longword vectors plus a -1L terminator.  Exec
disambiguates on the first word: -1 => word-offset table, otherwise
absolute longs.  The table's first word here is 0x0000 (high word of
the LibOpen pointer), so the absolute interpretation applies.  This
is the older/standard form produced by the Commodore library
skeleton of the era.
