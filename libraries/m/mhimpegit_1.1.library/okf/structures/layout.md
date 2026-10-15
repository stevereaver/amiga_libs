# mhimpegit.library 1.1 — structures & layout

## Hunk file

- `HUNK_HEADER` names=0, hunks=2, first=0, last=1, sizes = {0x2aa, 0x04}
  longwords — hunk1 is **allocated 16 B but only a 4 B DATA body is
  stored** (`0x3ea` + size 1 + `00000000`).
- hunk0 CODE 2728 B @ file 0x24.
- DREL16 reloc block `0x3f7` @ 0xacc: u16 `(count, hunk, off…)` groups —
  39 fields -> hunk0, 67 fields -> hunk1 (the near-data globals).
  4-byte zero terminator, `0x3f2` END, then hunk1 DATA + END.
- The `0x3f7` offset lists are in a quirky unsorted order (producer-
  specific); `source/fixup.py` hardcodes them to reproduce it exactly.

## RomTag / InitTable (hunk0)

- RomTag @0x2c4: `0x4afc`, AUTOINIT (flags 0x80), version 1,
  NT_LIBRARY (9), pri 0; name ->0x2b0, idstr ->0x25b, init ->0x344.
- InitTable @0x344: dsize=0x2c, ftab=0x2e0 (14 vectors + ffffffff),
  dtab=0x31c, initfn=0x134.
- datatab sets ln_Type=9 (`e000` cmd: byte store of high data byte),
  ln_Flags=6, ln_Name, lib_Version=1, lib_Revision=1 (`d000` cmd:
  word store), lib_IdString; terminator `0000`.

## Library data (dsize 0x2c)

- +0x10 NegSize = 84 (14 vectors), +0x12 PosSize = 0x22+0x2c.
- +0x18 IdString, +0x20 OpenCount (w), +0x24 seglist, +0x28 sysbase.

## Near-data globals (hunk1 `_gd`, 16 B)

| off | contents |
|-----|----------|
| +0  | SysBase copy (written by initfn, read via `(x).l` absolute) |
| +4  | IntuitionBase |
| +8  | DOSBase |
| +0xc| PreludeBase (set/cleared by AllocDecoder/FreeDecoder) |

All `_gd` accesses are absolute-long references relocated into hunk1 —
the SAS/C near-data model.

## Decoder context (16 B, MEMF_CLEAR)

`{+0 name, +4 mode, +8 queue count (l), +0xc -> MinList}`; the MinList
lives in a separate 12 B AllocVec block.

## Queue node (18 B)

`{+0 succ, +4 pred, +8 buffer, +0xc length, +0x10 played-flag (w)}` —
enqueued via exec AddTail, drained via RemHead + FreeVec.

## prelude.library side-channels

- `prelude+0x14/+0x16`: version/revision words (need >5.x or 5.6+).
- `prelude+0x38` -> module descriptor; byte+0x15 bit0 = MPEGit present.
- `prelude+0x8e` -> hardware state object; +0x10 (l) = active-buffer
  counter compared against the decoder's queued count.
- prelude LVOs used: -0x5a (tag config), -0x3c (buffer notify,
  signature d1=0x1008/d2=0x5622), -0x54 (d0=0x80 stop-ish), -0x24.
