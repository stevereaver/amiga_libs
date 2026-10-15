---
file: defects
---
# Findings

- -24 functab slot is a literal 0 -> h0+0 stub (reserved hole).
- COLDSTART (rt_Flags=0) though an InitTable-style packed
  resident is used — init code path is manual MakeLibrary.
- Embedded '_`abcdefghijklmnopqrst' byte table at +0x76
  (keyboard/ascii map).
- 30 refs into the 16B BSS — global state pointers.
- Functab literal-0 hole + trailing data longs interleaved
  after the ffffffff terminator (dead table cells).
