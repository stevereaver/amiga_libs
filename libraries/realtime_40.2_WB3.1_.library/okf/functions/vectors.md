---
file: vectors
---
# Vectors

19 LVOs (-6 .. -114) via word-offset functab@h0+0x5a.

Standard open/close/expunge/reserved + 15 user vectors —
LockRealtime/UnlockRealtime/CreatePlayerA/DeletePlayer/
SetPlayerAttrsA/GetPlayerAttrs/SetConductorState/ExternalSync/
NextConductor/FindConductor/SetSongAttrsA/GetVectorInfo-style
realtime API; last 5 slots share one 'not implemented' body
(->h0+0x168).

initfn@h0+0x84 opens utility.library v37 (then closes it after
initializing version-dependent fields).
