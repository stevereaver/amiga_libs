# pointer 33.2 — runtime layout

Library base (`Library` at +0); seglist stored at raw +0x22; runtime
data block ("pd") copied from the InitTable block into lib+0x32:

| pd off | field |
|--------|-------|
| +0x00  | reserved (0) |
| +0x04  | data size = 0x8a (part of InitTable) |
| +0x08  | funcTab pointer |
| +0x0C  | dataTab = 0 |
| +0x10  | init function (code +0x44) |
| +0x14  | ExecBase (from *(4)) |
| +0x18  | intuition.library base |
| +0x1c  | embedded spec {img->CHIP hunk, 16, 16, -6, 0, 0} |
| +0x34  | current spec pointer (fixup -> &pd->spec, i.e. +0x1c) |
| +0x38  | IFF property list {ILBM/BMHD, ILBM/CMAP, ILBM/GRAB, -1} |
| +0x50  | fixup count (1) -> later overwritten by dos.library base |
| +0x54  | fixup offset (0x34) -> later iffparse.library base |

Pointer spec (24 bytes):

| off | field |
|-----|-------|
| +0  | image allocation pointer |
| +4  | height |
| +8  | width |
| +12 | x offset (negated GRAB x) |
| +16 | y offset (negated GRAB y) |
| +20 | image alloc size = BODY cn_Size + 8 (embedded spec: 0) |

Spec is passed to intuition SetPointer as
{window, spec[0], spec[3], spec[4], spec[1], spec[2]}.

## InitTable (in DATA hunk at +4)

`{0x8a, ->funcTab, 0, ->initFn}` then the 0x50-byte data block above,
then fixup `{count=1, off=0x34}`.  LibInit copies 0x50 bytes to
lib+0x32, walks the fixup list repointing pd+0x34, stashes the
seglist at raw+0x22 and ExecBase at pd+0x14, opens intuition v33,
tries the BusyPointer ILBM, falls back to the embedded spec.
