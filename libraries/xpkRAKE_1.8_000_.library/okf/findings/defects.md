# Findings & defects

- -36 allocates a fixed 128KB scratch + 12B ctx.
- Close underflows open count (65534).
- Deterministic invalid R/W near 0xffffffff during compression
  probing (downward walk off the stack region) — identical
  counts both sides.
