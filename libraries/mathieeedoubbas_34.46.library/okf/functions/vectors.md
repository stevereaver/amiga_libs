---
file: vectors
---
# Vectors (3 word-offset functabs, 16 entries each)

Shared lifecycle entries 0-3: open +0x18c, close +0x1aa,
expunge +0x150, reserved +0x18e.

Math vectors -30..-114 differ per table:
- tab@0x1e4 (FPU hw present): 0x10a0 0x1094 0x93e 0xc74
  0x6fa 0x704 0x10fa 0x1114 0x1132 0x114c 0x10ea 0x228
- tab@0x1c0 (no resource): 0xfb2 0xf74 0x93e 0xc74 0x6fa
  0x704 0xca6 0xc9c 0x9ec 0x714 0x24c 0x228
- tab@0x1158 (MathIEEE.resource): 0xfb2 0x37c 0x93e 0xc74
  0x6fa 0x704 0x3da 0x45c 0x4de 0x560 0x24c 0x228

Standard mathieeedoubbas LVO set: -30 IEEEDPFix, -36
IEEEDPFlt, -42 IEEEDPCmp, -48 IEEEDPTst, -54 IEEEDPAbs,
-60 IEEEDPNeg, -66 IEEEDPAdd, -72 IEEEDPSub, -78 IEEEDPMul,
-84 IEEEDPDiv, -90 IEEEDPFloor, -96 IEEEDPCeil (+2 spares).

Oracle: full functab-select matrix (resource x attn) +
IEEE double-pair exercise of all 12 math vectors per table.
