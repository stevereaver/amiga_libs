---
type: Structure
title: xpkRLEN params
---

# XpkSubParams

Standard XPK sublibrary argument block; fields used:

| off | field | use |
|-----|-------|-----|
| 0x00 | xsp_InBuf | input data |
| 0x04 | xsp_InLen | input length |
| 0x08 | xsp_OutBuf | output buffer |
| 0x0c | xsp_OutBufLen | pack bound: out+lit+4 <= out+this |
| 0x10 | xsp_OutLen | pack: written (byte count); unpack: ignored |
| 0x1c | xsp_Mode | ignored (single-mode sublib) |
| 0x34 | xsp_Sub[] | unused (codec allocates no workmem) |

The codec is workmem-free — packmem/unpackmem are both
advertised as 0 in the XpkMode.
