---
type: Finding
title: xpkRLEN quirks & defects
---

# Quirks & defects

## 1. 3-in-a-row lookahead reads past InLen

`in[cur]==in[cur+1]==in[cur+2]` is evaluated every
iteration including the last — reads up to 2 bytes past
the input.  Values only gate the run branch (a spurious
run at input-end is discarded by the `cur==end` terminator
path) but the bytes are touched.

## 2. Run emit has no output bound

The literal path reserves `lit+4` bytes of headroom before
flushing, but the `<-count><byte>` run token writes 2
bytes unconditionally — in principle 2 bytes can land past
the checked headroom (the +4 slack almost always covers it
in practice, but the emit itself is unguarded).

## 3. Decoder has no output bound at all

Literal counts copy blindly, run counts replicate blindly;
a corrupt stream overwrites the output buffer.  xsp_OutLen
is never written — the caller derives the count itself.

## 4. Stubs return d0-untouched

XpksPackFree (-42) and XpksUnpackFree (-60) leave d0
unchanged (whatever was in it on entry); XpksPackReset
(-48) explicitly returns 0.  Observably equivalent to 0 —
the reconstruction returns 0 for all three.

## 5. SAS/C copy+fixup init duplicates the descriptor

The whole 256-byte template (InitTable + strings +
XpkInfo/XpkMode) is copied into the library base at
base+58, so the lib image carries a second copy of its own
InitTable and descriptor.  XpksPackerInfo returns the
base-resident copy (base+224), not the hunk copy.
