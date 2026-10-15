---
file: defects
---
# Findings

- Packed resident; loads execbase via `moveal 4,a6` (hardwired $4)
  instead of taking a6 — fine on real exec.
- Plain resident (flags 0): rt_Init IS code — no InitTable.
- 14 relocs target the BSS hunk — code holds pointers into
  runtime state.
- Most vectors early-out to a 0x7b sentinel when neither
  mmv88.library nor mmv8.library can be opened (stub forwards).
- RELOC32 offsets are listed in descending order per group
  (kept verbatim via spliced tail).
- Unlike 6.00 there is no 'Stub for using mmv8 or mmv88
  transparently' banner; minimum versions bumped to
  mmv88.library v8 / mmv8.library v22.
