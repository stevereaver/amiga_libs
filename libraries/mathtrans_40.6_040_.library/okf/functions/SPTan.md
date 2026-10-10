---
type: Function
title: SPTan
description: FFP tangent; sine/cosine quotient kernel, LVO -48.
---

# SPTan — LVO -48

`float SPTan(d0 parm)` — FFP arg, FFP result.

Shares the trig reduction (`floor(x*4/pi)` mod 16,
Cody-Waite remainder against pi/8); even octants use
sin(r)/cos(r), odd octants use -cos(r)/sin(r) — the
reciprocal avoids the pole that tan has at pi/2 offsets.
