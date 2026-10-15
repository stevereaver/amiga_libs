---
file: defects
---
# Findings

- RELOC32 splits the functab across two groups (15 + 4 slots)
  for no structural reason — linker artifact preserved verbatim.
- Most high-LVO slots alias one -14-returning unimplemented stub
  (+0x24a); -30 info block is static code-embedded data.
- Unpack of corrupt/crypt-trailer streams deterministically
  returns -14 (0xfffffff2).
