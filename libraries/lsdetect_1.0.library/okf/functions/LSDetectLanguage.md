---
type: Function
title: LSDetectLanguage
description: Detect user language with three fallbacks; cache in base+35.
lvo: -30
registers: a6 base -> d0 0|1|2
timestamp: 2026-10-10T20:40:00Z
---

# ``LONG LSDetectLanguage(void)``

**LVO -30**

If the cached byte at base+35 is >= 0, returns it.  Otherwise:

1. `lowlevel.library` present → `GetLanguageSelection()`:
   6 → **0**, 3 → **2**, anything else → **1**.
2. else `locale.library` → `OpenLocale(0)`; compares the first
   longword of `loc->loc_LanguageName` (locale+4):
   `"ital"` → **0**, `"deut"` → **2**, else **1**; `CloseLocale`.
   OpenLocale failure falls through to step 3.
3. else/with failure → `dos.library`: opens
   `RAW:0/0/600/120/Language Selection` (MODE_OLDFILE), writes a
   94-byte prompt (F1 - Italiano / F2 - English / F3 - Deutsch),
   then `Read`s 1 byte at a time skipping until `0x9b` (CSI) and
   takes the next byte minus '0' when it is 0..2 → result.
   Errors/unavailable dos → **1**.

Result is stored in the cache byte and returned.
