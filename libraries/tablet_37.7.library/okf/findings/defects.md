---
type: Findings
title: tablet 37.7 quirks
---

# Findings / quirks

- rt_Version = 33 (0x21) while the library reports 37.7 —
  the resident's version byte disagrees with both the idstring
  and the lib_Version=37/lib_Revision=7 written by initfn.
  Harmless (exec ignores it for AUTOINIT loads) but it means
  version-scanning tools see a v33 module.
- Dead code in installer h0+0x964: after `cmpw #39,d1;
  bhis` (skip patch when intuition >=39) the `cmpw; bne`
  re-test is always true for <39, so the 'v37 needs revision
  >=2192 (0x890)' refinement at h0+0x9a2 is unreachable —
  every intuition <39 is patched regardless of revision.
- functab slot 3 is a genuine 0 hole (not -1): for absolute-
  long tables exec leaves the reserved -24 vector at its
  default rather than installing h0+0's rts stub.
- rt_Init = h1+4: the data hunk's first longword is an unused
  zero slot preceding the InitTable.
- No InitData (datatab = NULL): all Library fields (ln_Type,
  ln_Name, lib_Flags=6, lib_Version/Revision, lib_IdString)
  are poked by initfn code instead — unusual for an AUTOINIT
  lib of this era.
- initfn relocates the whole DATA hunk into the library node by
  hand (0xc4-byte copy at h0+0x80, then a fixup loop driven by
  the h1+0xc4 count / h1+0xc8 offsets) — a homegrown
  'relocate initialized data' step since the compiler emitted
  absolute references.
- `lea 0x31,a0` + `lsl #2` used twice to build the constant
  0xc4 — compiler idiom, transcribed verbatim.
- 'APCommand' occurs three times in the data hunk (h1+0x62/
  0x6c/0x76) — the compiler didn't deduplicate the string
  literal; each FindPort callsite uses a different copy.
- The installed Interrupt node's ln_Name points at the second
  'intuition.library' string (h1+0xb2), so the input.device
  handler lists under that name.
- Vector -42 >=39 path CopyMems 24B from priv+0x140 which is a
  20-byte buffer: bytes +8..+23 of the result are the lib's
  handler-trampoline and private-base pointers (incl. an
  absolute lib address leak at out+16/+20).
- Close decrements opencnt with no floor — repeated closes can
  underflow it (and Expunge relies on the deferred-flag
  interplay); Open has no range checks either.
- Uninstall replays DoIO cmd 10 then 9 with swapped payloads
  vs install; the payload lives at ioreq+40 (io_Length slot),
  not io_Data — device-private 'TabletPatch' handshake.
