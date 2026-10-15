---
file: vectors
---
# Vectors

16 LVOs (-6 .. -96) via the selected word-offset functab:

open/close/expunge/reserved + 12 double-precision functions
(IEEEDPFix/Flt/Abs/Neg/Add/Sub/Mul/Div/Floor/Ceil/Cmp/Tst family).
Traced results confirm IEEE double format (-96 -> 0x3ff00000 = 1.0
high word; -84 -> 0x7ff10000 NaN high word for the stub inputs).

initfn: seglist -> abs $17e, OpenResource fpsp.resource, attn-bit4
probe, functab pick, MakeLibrary(-84) dsize 0x40 datatab->0xf2,
lib_Name/lib_IdString/lib_Flags/lib_SysBase/lib_res fields
hand-filled, AddLibrary(-396), returns lib base.
