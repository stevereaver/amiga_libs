---
file: vectors
---
# Vectors

6 LVOs (-6 .. -36), absolute functab@h0+0x158 ->h0:
open +0x21e, close +0x22c, expunge +0x174, reserved +0x21c,
AvailFonts ->h3+0x12, LoadFont-family ->h3+0.

Observed: AvailFonts allocs 0x104 header + dos Open/Read/
Seek/IoErr (-84/-126/-102/-108) on FONTS: enumeration;
expunge closes dos+graphics then FreeMem.
