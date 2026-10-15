---
file: vectors
---
# Vectors

19 LVOs (-6 .. -114), absolute functab@h0+0x6c:
-6 open +0xf6, -12 close +0x104, -18 expunge +0x11a,
-24 reserved +0x248(0), -30 XpkPackerInfo +0x156,
-36 XpkPackChunk +0x15e, -42 ctx-free +0x24a,
-48/-60/-66/-72/-78/-84/-90/-96/-102 unimpl ->+0x24a(-14)
except -54 XpkUnpackChunk +0x224... see functab in source;
-108/-114 real routines +0x498/+0xd9c/+0x4a2/+0xd5c.

PackerInfo: 'IMPL'/'Turbo Implode 1.0', flags 0x8009,
6-mode table (0.1x..1.0x + adaptive). Pack emits 'IMP!'
header; crypt-trailer path via xsp+0x20 userdata.
