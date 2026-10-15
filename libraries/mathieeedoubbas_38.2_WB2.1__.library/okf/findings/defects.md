---
file: defects
---
# Findings

- 4B body overrun `eec4ffff` before RELOC32 (declared
  size smaller than physical, same as 34.46).
- 3 trailing empty hunks (CODE,CODE,DATA) — likely a
  linker template artifact.
- flags byte 0x01 not 0x80; init is CODE (COLDSTART).
- Init returns different lib base/functab per fpsp/attn
  combo; hdr fields only set on success.
