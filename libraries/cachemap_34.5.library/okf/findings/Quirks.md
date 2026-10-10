---
type: Finding
title: Quirks
description: Oddities found in the shipped binary.
timestamp: 2026-10-10T19:30:00Z
---

# Quirks

- LibExpunge frees the *plane buffers* of unlocked nodes but leaves
  the node blocks allocated and linked; when the count reaches 0 the
  library is freed anyway, orphaning the nodes (leak by design).
- LibClose only decrements the private count — it can never cause
  an expunge; LIBF_DELEXP is also never used.
- CreateMap allocates nodes with flags `0x00010001`: MEMF_CLEAR
  plus a low bit that does not match a documented MEMF_ constant
  (recorded verbatim).
- The LVO -24 slot points backwards to the module entry, not to a
  stub.
- No public function names exist in the binary — all API names in
  this bundle are reconstructed.
