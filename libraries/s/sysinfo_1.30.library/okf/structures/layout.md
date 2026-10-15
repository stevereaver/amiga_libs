---
type: Structures
title: sysinfo 1.30 layout
---

# Layout

- datasize 0x4c -> 34B node + 42B private.
- No datatab; initfn@h0+0x20 fills lib fields itself.
- h1+0x14 second relocated pointer ->h0+0x206 (string 'Executive_server'
  area?).
