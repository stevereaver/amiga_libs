---
type: Finding
title: Unused base field
description: dataSize is 0x2a but the +0x26 long is never touched.
timestamp: 2026-10-10T09:40:00Z
---

# Unused base field

`dataSize` 0x2a gives the base `Library + SegList + one spare long`.
LibInit stores only the seglist; nothing ever reads or writes base
+0x26..0x29. The skeleton probably derives from one that kept SysBase
or the XpkInfo pointer there (xpkNONE_1.4 uses it for `xsb_SysBase`);
here ExecBase comes from `4.W` and the info pointer is `lea`-computed
per call.
