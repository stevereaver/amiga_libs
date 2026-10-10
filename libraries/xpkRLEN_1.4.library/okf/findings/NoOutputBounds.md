---
type: Finding
title: No output bounds in the decoder
description: XpksUnpackChunk never consults xsp_OutBufLen.
timestamp: 2026-10-10T09:40:00Z
---

# No output bounds in the decoder

The decoder loops until a 0x00 terminator and never compares the
output pointer against `xsp_OutBuf + xsp_OutBufLen`. A corrupt or
hostile stream writes past the buffer with no error return. The
encoder *does* bound its writes (against `outlim`, returning
`XPKERR_EXPANSION`), so the asymmetry is intentional-looking:
xpkmaster knows each chunk's unpacked size and allocates exactly.
