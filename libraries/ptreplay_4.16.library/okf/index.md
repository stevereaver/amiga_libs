---
type: Library
title: ptreplay.library 4.16 (03.01.95)
description: >-
  ProTracker .MOD replay library.  Playback runs on spawned
  "ptreplay_server" + "ptreplay_ctrltask" processes; this binary
  is the client API + module parser front-end.
timestamp: 2026-10-15T10:30:00Z
---

# ptreplay.library 4.16

The widely-used ProTracker replay library (embeds a HEADDBGV01
debug hunk before the code hunk).  16 user vectors; module layout
offsets are the canonical M.K. format (songlen +950, pattern
table +952, magic +1084).

## Binary facts

- 6816 bytes; CODE hunk 0x197c + leading HUNK_DEBUG (HEADDBGV01)
- RomTag AUTOINIT v4 r16; functab has a slot-4 module entry -> start
- strings: ptreplay_server, ptreplay_ctrltask, dos.library

## API

| LVO | Name | Notes |
|-----|------|-------|
| -30 | PTLoadModule | validate+init player block |
| -36 | PTUnloadModule | release |
| -42 | PTPlay | state word +12 = 1 |
| -48 | PTStop | state word +12 = 0 |
| -54 | PTPause | alias of stop path |
| -60 | PTResume | d0 = retrigger flag |
| -66 | PTSetVolume | vol 0..64 (needs live engine handle) |
| -72 | PTSongPos | reads pos byte at handle-12 |
| -78 | PTPatternPos | module+950 |
| -84 | PTSongLen | returns &module->pattab (+952) |
| -90 | PTGetChan | (handle-4).w >> 4 |
| -96 | PTGetSample | &module+1084 ("M.K." region) |
| -102 | PTSetPri | pri+1 bias |
| -108 | PTMute | allocs 0x16c control block |
| -114 | PTClearChannelPtrList | clears channel list |
| -120 | PTGetModName | module base selector |

## Status

FULL - all 16 LVOs resolved+documented; C model reproduces the
handle/state semantics; replay engine internals (server task) are
out of scope for the client lib.

## Contents

- [functions/](functions/index.md) - [structures/](structures/index.md)
- [findings/](findings/index.md) - [log.md](log.md)
