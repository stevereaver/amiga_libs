---
file: defects
---
# Findings

- Id string contains an embedded LF (0x0a) — '\r\n'
  inside the $VER line, unusual.
- PackerInfo banner has typos: "Comressing" (sic) and
  "Expanding".
- Mode name is 'minimal' — single-mode codec.
- 3 NULL vector holes (reserved XPK slots).
