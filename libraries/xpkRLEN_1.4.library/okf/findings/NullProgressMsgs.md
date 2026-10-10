---
type: Finding
title: NULL progress messages
description: All four xi_*Msg pointers are zero.
timestamp: 2026-10-10T09:40:00Z
---

# NULL progress messages

`xi_PackMsg`, `xi_UnpackMsg`, `xi_PackedMsg`, `xi_UnpackedMsg` are all
NULL — xpkmaster falls back to generic progress strings (or none).
The 1.5 rebuild fills them in ("Packing"/"Unpacking"/"Packed"/
"Unpacked"), so the NULLs were an oversight fixed later.
