---
type: Structures
title: Bootblock.library 3.1 layout
---

# Layout

- datasize 0x5e -> 34B node + 94B private (port, task, dos/exp
  bases, buffers).
- hunk2 = 96B zero-initialized DATA — shared globals space used
  by both code hunks (referenced by absolute relocated operands).
- Private fields: seglist/exec/dos/expansion bases, MsgPort,
  request blocks.
