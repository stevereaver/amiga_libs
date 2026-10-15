# Algorithms

Client/server playback: library calls set the module's state word
and positions; the spawned server task performs the actual
ProTracker tick + Paula writes.  Player-state machine lives in
the server (documented in work/pt.asm).
