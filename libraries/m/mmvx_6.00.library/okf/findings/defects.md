---
file: defects
---
# Findings

- Packed resident; loads execbase via `moveal 4,a6` (hardwired $4)
  instead of taking a6 — fine on real exec.
- Plain resident (flags 0): rt_Init IS code — no InitTable.
- 14 relocs target the BSS hunk — code holds pointers into
  runtime state.
- Most vectors early-out to a 0x7b sentinel when the mmvx.resource
  isn't present (stub returns 0 -> sentinel compare).
