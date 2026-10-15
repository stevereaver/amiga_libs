---
type: Structure
title: ConstantPool
description: Inline IEEE-64 coefficient pool at hunk 0x1760.
---

# Constant pool — hunk+0x1760

The software kernels reference IEEE-64 constants both as
inline `fXXd #0xXXXXXXXXXXXXXXXX` immediates and through
a small tail pool addressed pc-relative:

| off    | bytes              | value                | name    |
|--------|--------------------|----------------------|---------|
| 0x1760 | 3fe0000000000000   | 0.5                  | _chalf  |
| 0x1768 | 3ff0000000000000   | 1.0                  | _cone   |
| 0x1770 | 4000000000000000   | 2.0                  | _ctwo   |
| 0x1778 | 00000000           | 0 (4-byte long only) | _czero  |

Note `_czero` is a single longword, not a double — the
code region ends at 0x177c total.

Key inline immediates used by the kernels include pi
(0x400921fb54442d18), pi/2 (0x3ff921fb54442d18), pi/4
(0x3fe921fb54442d18), 4/pi (0x3ff45f306dc9c883 =
1.2732395447351628), 1/16 (0x3fb0000000000000), 16
(0x4030000000000000), log10(e) (0x3fdbcb7b1526e50e =
0.4342944819032518), ln2 (0x3fe62e42fefa39ef),
sqrt(1/2) (0x3fe6a09e667f3bcc), +inf
(0x7ff0000000000000), NaN (0x7fffffffffffffff), plus
per-function minimax coefficient sets.
