---
type: Structures
title: launcher 41.9 layout
---

# Layout

- datasize 0x64 -> 34B node + 0x46B private (incl. task/ports
  at +92/+96).
- h1 DATA packs 'CON:0/25/640/150/' + '/AUTO/WAIT' strings,
  the functab@0x1e, and the InitTable@0x38.
