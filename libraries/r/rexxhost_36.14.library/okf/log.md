---
file: log
---
# Work log

- 2026-10-15: 3-hunk layout decoded — resident pointer fields live
  in the DATA hunk (cross-relocated both ways); InitTable inside h1.
  Mnemonic transcription desynced on aN@(-disp) forms (gas drops
  opcode words) so hunk0 emitted as verbatim .byte stream; hunk1 raw
  data; hunk2 4B BSS. fixup.py splices both REL32 groups.
  BYTE-IDENTICAL.
- machine68k oracle: init opens dos+rexxsyslib unversioned; 21
  vectors traced; open-underflow + Remove/FreeMem expunge identical.
  RUNTIME-IDENTICAL. Plane AMIGALIBS-290.
