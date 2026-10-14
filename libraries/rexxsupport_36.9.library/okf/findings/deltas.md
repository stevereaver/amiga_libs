# rexxsupport.library — 34.9 → 36.9 deltas

Byte-level diff of the two code hunks (34.9 = 0x970 bytes,
36.9 = 0x988 bytes, +24).  Everything below is verified
against the original binaries; the 36.9 reconstruction is
byte-identical to its original.

## 1. InitTable / datatab

| | 34.9 | 36.9 |
|---|------|------|
| ifn offset | +0x5e | +0x58 |
| datatab | `8036 8008 002c 2a00` + **`8018 002e`** (IdStr) + `8040 001a 00ff 0080` | `8036 8008 002c 2a00` + `8040 001a 00ff 0080` |
| reloc count | 10 (extra at code+0x56 = IdStr ptr) | 9 |

The `8018` (8-bit offset, long) record that wrote `_idstr` into
`lib_IdString` (+24) is gone; initfn does it in code instead
(see below).  Net datatab shrinks by 6 bytes → initfn moves
from 0x5e to 0x58 and there are 9 relocs instead of 10.

## 2. initfn (+0x58, was +0x5e)

34.9:
```
movel d0,a5
movel a0,a5@(42)        ; seglist
movel a6,a5@(34)        ; SysBase
lea  _rxsname(pc),a0
moveq #36,d0            ; version 36 required
jsr  a6@(-552)
```

36.9:
```
movel d0,a5
movel a0,a5@(42)        ; seglist
movel a6,a5@(34)        ; SysBase
lea  _idstr(pc),a0
movel a0,a5@(24)        ; *** lib_IdString set in code ***
lea  _rxsname(pc),a0
moveq #0,d0             ; *** version 0: ANY rexxsyslib ***
jsr  a6@(-552)
```

Observable deltas:
- `OpenLibrary` version is **0** — 36.9 binds to any
  rexxsyslib.library, even older than v36.
- `lib_IdString` is written by code, so a hypothetical library
  created without running initfn would have IdString == 0.

## 3. Dispatcher (+0xe0, was +0xde)

Whole-body rework; the per-command handlers are unchanged.

- `clrl -(sp)` pushes a scratch slot for the result-buffer
  argstring pointer; popped into `a1` on every exit for
  DeleteArgstring.
- Register roles flipped: `a6` = RexxSysBase for the whole
  body (`a4` = libbase).  34.9 kept `a6` = libbase and `exg`ed
  around each rxs call; 36.9 `exg`s once at entry and once
  around the handler call (handlers keep `a4`=rxs, `a6`=lib).
- ExecBase fetch uses `d4`/`a0` scratch swap:
  `a5@(34)→a0→d4` — same source, same register.
- **Result buffer**: `moveq #100,d0; lslw #2; subal a0,a0;
  jsr a6@(-126)` — `CreateArgstring(0, 400)`; its data pointer
  becomes `a3`.  34.9 read `a3 = *(a2+136)` (a caller-owned
  buffer in the task block); **T+136 is never touched in
  36.9**.  The scratch argstring is freed via rxs-132 on
  *every* exit — including unknown-name (`a1=0` →
  DeleteArgstring(NULL)) and alloc-failure paths.
- Jump-table dispatch: 34.9 `exg; jsr jtab-indexed` indexed
  with brief-extension disp -2 (offsets relative to the jsr);
  36.9 uses disp **-4** (offsets relative to the pre-jsr
  `exg` at jvec=0x194).  Same net flow: `a6` is rxs before
  the jsr, `exg` swaps a4/a6 so the handler sees a4=rxs,
  a6=lib; `exg` after return restores.
- Result packaging identical: bit31 raw (a3/d3), bit16
  numeric (d3 → rxs-312), bit17 bool (rl_FALSE/rl_TRUE +8),
  bit18 empty (rl_NULL +8), no bits → a0 as-is.
- Common exit: `a2`=a0 saved, `a1`=(sp)+ scratch,
  rxs-132 DeleteArgstring, `a0`=a2 restored, `d0`=d6,
  `moveml (sp)+` — returns through `7f`/`ret`.  34.9 had no
  free step (nothing to free) and exited straight after the
  flag tests.

## 4. LibClose tail (+0x90)

34.9 emitted its own copy of the "re-set DELEXP, retest, rts"
sequence inside Close and then `bras Expunge`.  36.9 `bsr`s
into a shared subroutine at the head of Expunge
(`bset #3,14(a6); btst #3,14(a6); rts`) and *falls through*
into Expunge — same observable behavior, 8 bytes shorter and
the only non-dispatcher layout change in the lifecycle block.
(The Close/Expunge shared-body layout is why the
reconstruction's `bsrs` + fall-through matters for byte
identity.)

## 5. Everything else

- Command table, argflag bytes, index tables, `jtab` (words
  re-based to the new jvec), `doscall`, `argbyte`, `sf_num`,
  `sl_devscan`, all 23 handlers, `sf_tab`, strings: **byte-
  identical or PC-relative-shifted only**.  All 34.9 defects
  (see `findings/defects.md` there) carry over unchanged —
  FORWARD's stale-`d2` PutMsg, SHOWLIST '@' dead selector,
  OPENPORT stale-`d3`, TYPEPKT 'A' = argc, GETARG silent empty,
  REPLY flag drop on rc≠0, UnLock(0), err3 leaks.
- RomTag pad word differs cosmetically: 34.9 pads with `0000`,
  36.9 with `4e71` (nop).
- File grows 2524 → 2528 bytes (single CODE hunk 0x988; 34.9
  had an extra empty BSS hunk).

## 6. Why the rework (inferred)

34.9 trusted the caller's task block to supply a result buffer
at `*T+136`.  36.9 allocates its own fixed 400-byte scratch
argstring per dispatch and always frees it — insulating the
library from task-block corruption and matching the "empty"
result path (`!NULL` etc.) which no longer depends on caller
state.  Keeping `a6`=rxs through the body also removes a dozen
`exg` pairs.
