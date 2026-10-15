# Findings & defects

- Trailing empty CODE hunk (tag+size0+END) — original linker
  emitted it; pooling fixup pre-seeds empty pool entries.
- Close underflows open count (65534).
- 2021 re-release of the 41.x series.
