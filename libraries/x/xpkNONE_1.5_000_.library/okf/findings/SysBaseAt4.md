---
type: Finding
title: ExecBase from absolute 4.W
description: No xsb_SysBase field; Expunge and UnpackChunk read 4.W directly.
timestamp: 2026-10-10T09:20:00Z
---

# ExecBase from absolute 4.W

Both exec call sites (Remove/FreeMem in
[LibExpunge](../functions/LibExpunge.md), CopyMem in
[XpksUnpackChunk](../functions/XpksUnpackChunk.md)) load a6 from
absolute `4.W` (`movea.l ABSEXECBASE.W,a6`) instead of a base field.
Consequently `dataSize` is 0x26 (Library + SegList only) and LibInit
is a minimal 3-instruction function — it doesn't even save SysBase,
which the 1.4 skeleton did.

Reading `4.W` is architecturally safe on all classic Amigas but is
exactly the pattern the older 1.4 code avoided; clearly different
skeleton sources.
