# easyrexx.library 1.78 — quirks & defects

## Defects (original library bugs, reproduced verbatim)

- **Out-of-bounds near-data global**: the four rexxsyslib call thunks
  (_th4c/_th64/_th7c/_th98) load their target base with
  `movea.l (gd+0x18).l, a6`.  gd+0x18 is byte 24 of the data section,
  but hunk1 is exactly 24 B — the address lies one longword PAST the
  hunk.  Nothing anywhere writes that location, so on real hardware
  the thunks `jsr -LVO(a6)` on garbage — the -96 SendCmd path is a
  latent crash.  The DATA hunk evidently should have been 32 B with a
  `RexxSysBase` global at +0x18 (the initfn never stores to h1).
- **Uninitialised a4 convention**: -54 (key lookup) and -66 (arg
  init) read `a4@0x1c`/`a4@0x20` (utility/dos bases at lib+0x4c/0x50)
  without setting a4 — they rely on the caller passing a4 = lib+0x30,
  the SAS/C near-data base.  Calling either vector cold with a random
  a4 jumps through a wild pointer.
- **_v84 partial-failure leak**: the success test is `!(port==0 &&
  obj==0)` — if exactly one of CreateMsgPort / dos -0xe4 succeeds the
  host is returned half-built (obj@0x12 or port@0 may be NULL);
  only total failure triggers the _v78 cleanup path.
- **Dead rebase code**: initfn copies h1's 24 B into lib+0x30 and
  contains a relocation-fixup loop driven by gd+0x14 — which is 0, so
  the loop body never runs.  Likely a vestigial SAS/C crt path.
- **_v84 unused tag 0x80000004 semantics**: sets the port override
  pointer and clears the create flag but the value's role is only
  partially exercised in observed paths.

## Encoding quirks (reproduced byte-exactly)

- **Mid-instruction dual entries**: branches land inside `cmpi.w`
  immediates at 0x72e/0x97a/0x9b4/0x9c6 (dead `0c40` opcode word,
  operand bytes = `move.b (a1)+,(a0)+` / `move.l d0,d1` /
  `moveq #1,d7`) and inside the 0xa96 dead word `0000` before the
  4th rexx thunk.  The oracle-driven disassembly emits `.short` pairs
  with the label inside.
- **Noncanonical immediates** gas would canonicalise: `moveq #-1` /
  `moveq #-0x1e` / `moveq #-0xa` forms, plus `.short`-emitted
  `0x2b7c`-class move.l #imm sites.
- **`XONu`-type ASCII artifacts**: string-scan bait like `58 4f 4e 75`
  ("XONu") before 'EASYREXX' is code (`addq.w #4,a7; rts`), not data.
- **RELOC32 ordering**: offsets stored descending (0xa14->0x9d4)
  then ascending smalls (0x5a,0x34,0x16,0x12,0xa,0x6) — producer
  quirk, preserved by fixup.py.
- **rexxsyslib opened at version 0** (any version accepted), while
  utility/dos require v37.
- The `0x0a00` word @0x1d8 doubles as a `"\n"` string argument to the
  '%s%s' sprintf that appends a newline to command strings.
