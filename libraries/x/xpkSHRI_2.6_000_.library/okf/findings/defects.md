---
file: defects
---
# Findings

- Same InitTable/functab shape as the 020 build but larger
  code (4172B vs 4084B) and shifted targets.
- Unpack of garbage input still walks unmapped memory
  deterministically (matching oracle invalid counts).
- -42 and -60 alias the same ctx-free routine +0x11a.
- gen quirk handled: objdump merges boundary words into pairs —
  data spans must re-emit straddling token tails.
