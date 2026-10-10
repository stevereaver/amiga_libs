# cxb.library — task-context algorithm

Each opener registers a private 0x638-byte context so the
functions can run re-entrantly per task:

1. On `Open`, index the 128-slot {task,ctx} table at
   `base+48` by `(ThisTask & 0x380)`.
2. Under `Forbid`, scan up to 16 slots (8-byte stride) for an
   empty one; `Permit`.
3. `AllocMem(0x638)`, open dos/intuition/graphics v33 into
   the header, store `{ThisTask, ctx}` in the slot.
4. On `Close`, find the slot whose task matches `ThisTask`,
   close the three bases and `FreeMem` the context.

The table's per-region spill of 16 lets up to 16 tasks share
one `0x380` index.  See findings for the half-cleared-table
defect.
