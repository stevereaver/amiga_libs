---
file: vectors
---
# Vectors

16 LVOs (-6 .. -96) via the selected word-offset table (functab B in
the default no-resource path):

open/close/expunge/reserved + 12 single-precision functions:
IEEESPFix/Flt/Abs/Neg/Add/Sub/Mul/Div/Floor/Ceil/Cmp/Tst-style set
(vector -60 returns 0x80000000 for a -0.0-style operand, -84 returns
0x7f880000 = NaN-ish result for the traced inputs — IEEE single
format confirmed).

initfn: `move.l a0,$1f2` (seglist stash in low memory), btst #4 on
a6+297 (AttnFlags AFF_68881), OpenResource('MathIEEE.resource'),
MakeLibrary(functab=selected, datatab=0x12a, initfn=0, dsize=0x3c,
seglist=0), AddLibrary, then hand-fills lib_Version/lib_Revision /
lib_IdString.
