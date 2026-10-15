---
file: vectors
---
# Vectors

Word-offset functab @hunk0+0x94, offsets relative to functab base
(0xff6c wraps to hunk+0 = the `moveq#0/rts` stub).

| LVO | target | role |
|-----|--------|------|
| -6  | +0xb4  | Open |
| -12 | +0xc2  | Close |
| -18 | +0xd4  | Expunge (Remove + FreeMem(0x84... observed 132B)) |
| -24 | +0x00  | reserved -> stub |
| -30 | +0x152 | XpkPackerInfo -> info block @hunk0+0xcb4 (LINO4, 3 modes) |
| -36 | +0x15a | XpkPack |
| -42 | +0x112 | XpkAlloc... (pack work alloc) |
| -48 | +0x00  | reserved -> stub |
| -54 | +0x932 | XpkUnpack |
| -60 | +0x134 | XpkFree / work-free |

Verified end-to-end: 19 pack buffers round-trip, mode 30/60/100
select submode 12, passworded pack (pw-hash in hdr0) rejects bad
passwords with XPKERR, PackFree/UnpackFree return -32.
