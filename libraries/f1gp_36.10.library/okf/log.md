---
file: log
---
# Work log

- 2026-10-15: 2-hunk hybrid 68k/PPC f1gp 36.10; raw `.byte`
  emission for both hunks, fixup splices headers+tails,
  preserving the h1 alloc>size quirk. BYTE-IDENTICAL.
- machine68k oracle (mmvx COLDSTART harness, entry@+0x6c):
  bss-clear + dual-probe init path -> MakeLibrary 11 vectors,
  all vectors + expunge traced. RUNTIME-IDENTICAL,
  0 invalids. Plane AMIGALIBS-309.
