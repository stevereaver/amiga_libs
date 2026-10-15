# Findings & defects

- initfn returns 0 under stubs after closing utility.library and
  FreeMem(0x100072,0x164) — the utility open result gating differs
  from iffparse_42.2(BUGGED) which used a word-offset functab.
- Close underflows open count: after close x2 -> cnt=65534
  (classic unguarded decrement).
- 7 deterministic invalid accesses during vector probing.
