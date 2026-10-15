---
file: defects
---
# Findings

- Only 4 vectors (open/close/expunge/stub) — all logic
  runs at init: patches intuition for CyberGraphX
  (alert emu, no-chip-screen, savemem env switches).
- DREL16 tail (22 word slots).
- Lib name in the data string area is "xcyberintuition"
  (@0x3d) — the 'x' is likely a flag byte being part of
  the literal; actual rt name is "cyberintuition.library".
