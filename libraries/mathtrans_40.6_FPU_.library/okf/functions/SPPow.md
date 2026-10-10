---
type: Function
title: SPPow
description: FFP power routine at LVO -90.
---

# SPPow — LVO -90

`float SPPow(d1 power, d0 arg)` — FFP power in d1, FFP arg
in d0; FFP result `arg^power` in d0.

For arg > 0: `exp(y * ln(x))` — `flogns`/`fmuls`/`fetoxx`.

For arg < 0 (the IEEE sign survives the input conversion, so
`bmi` on the converted value): the arg is made absolute
(`bclr #31`), the FFP power is converted, `fints`+`fsubs`
tests integrality — a non-integral power returns FFP 0.
Otherwise `|x|^y` is computed and the IEEE sign is restored
(`bset #31`) only when `fmod(y, 2.0) != 0`, i.e. odd powers
keep the result negative.  arg = 0 takes the positive path
(flogn(0) = -inf => result 0 through the converter).

Same algorithm as the mathieeesingtrans build's IEEESPPow,
re-expressed with FFP<->IEEE conversions.
