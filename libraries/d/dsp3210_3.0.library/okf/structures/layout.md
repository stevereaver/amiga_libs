---
type: Structures
title: dsp3210 3.0 layout
---

# Layout

- dsize arg to MakeLibrary = 46 (+34 node) -> 80B node.
- In-hunk structures: 'timer', '*icnt', '.ocnt', '3dmac'
  DSP3210 hw-register name strings at 0xc40+.
- Internal secondary ->h0 pointer table at 0xbec..0xc18.
