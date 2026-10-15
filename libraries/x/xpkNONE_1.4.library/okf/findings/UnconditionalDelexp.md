---
type: Finding
title: LibExpunge sets LIBF_DELEXP unconditionally
timestamp: 2026-10-10T19:45:00Z
---

# Unconditional DELEXP

`LibExpunge` executes `bset #3,lib_Flags` *before* testing
`lib_OpenCnt`, so the deferred-expunge flag is set even on the path
that actually removes and frees the library. Harmless — the base is
freed anyway — but a deviation from the usual skeleton, where the
flag is only set on the busy path. Reproduced verbatim in the C
reconstruction.
