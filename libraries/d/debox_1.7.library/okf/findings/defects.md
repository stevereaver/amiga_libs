---
type: Findings
title: debox 1.7 quirks
---

# Findings / quirks

- Non-AUTOINIT resident: no InitTable — initfn does its own
  MakeLibrary+AddLibrary.  Resident flags byte is 0.
- 'Copyright 1990, Silent Software' + '*** This program may not
  be freely distributed ***' strings inline in the CODE hunk
  head (ship-time license banner).
- One vector performs an unbounded stream read under stub
  arguments (INVALID flood in oracle — identical both sides).
