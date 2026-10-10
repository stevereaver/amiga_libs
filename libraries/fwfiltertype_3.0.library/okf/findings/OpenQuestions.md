---
type: Finding
title: Open questions
timestamp: 2026-10-10T19:15:00Z
---

# Open questions

- **Caller contract**: nothing in the binary names the structure whose
  +0x0c field FwFilterType reads (likely a filetype/filter descriptor
  with a 4-char type field), nor what consumes the returned 3/0 and the
  "fwpha" pointer. SoftWood shipped other "fw*" products (the string
  suggests a filter-name mapping `alph*` → `fwpha`).
- **Second reserved slot (-36)**: the function table has 6 entries —
  Open/Close/Expunge/Null/FwFilterType/Null — where the usual pattern
  has 5 (4 system + 1 user). Intentional padding to an even boundary or
  vestigial extra slot; harmless either way.
- **`$VER:` vs filename**: rt_Version and lib_Version both say 3.0 —
  consistent; no anomaly.
