---
type: Function
title: SPExp
description: FFP exponential; Cody-Waite kernel, LVO -78.
---

# SPExp — LVO -78

`float SPExp(d0 parm)` — FFP arg, FFP result.

Classic Cody-Waite exp: `n = floor(x*log2(e)+0.5)`,
reduced `r = x - n*ln2_hi - n*ln2_lo`, minimax
polynomial `P(r)` via `_exp_poly`, then ldexp-style
reconstruction `P * 2^n` by bit-level exponent
insertion (`_exp_dbl`/`_exp_sgl` handle the IEEE-64
exponent field directly).  Overflow -> huge FFP,
underflow -> 0.
