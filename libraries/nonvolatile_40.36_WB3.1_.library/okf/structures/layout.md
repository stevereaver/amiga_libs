---
type: Structures
title: nonvolatile 40.36 layout
---

# Layout

- datasize 0x9c -> 34B node + 0x7eB private.
- Two RomTags: library resident@+4 (AUTOINIT) and an
  AFTERDOS resident@0xd60 whose init deinstalls itself via
  exec -0x228/-0x19e and returns 0.
- Default NV path string 'SYS:prefs/env-archive/sys/
  nv_location' @0x8b1.
