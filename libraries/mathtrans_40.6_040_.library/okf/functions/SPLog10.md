---
type: Function
title: SPLog10
description: FFP base-10 logarithm, LVO -126.
---

# SPLog10 — LVO -126

`float SPLog10(d0 parm)` — FFP arg, FFP result.

Natural-log kernel (`_log_core`) scaled by the exact
IEEE-64 constant 0x3fdbcb7b1526e50e =
0.4342944819032518 (log10(e)).  Domain errors as per
SPLog.
