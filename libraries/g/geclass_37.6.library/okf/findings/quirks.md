---
type: Finding
title: geclass_37.6 quirks and oddities
---

# Quirks / notable findings

## CPU-level oddities

- **`rtd`** (`0x4e74 #imm`) is used for callee-pops in the scale
  helpers (#6), dispatcher epilogue (#12), resolver (#12) and
  strcmp tail (#16 via `lea`+`jmp`).  `rtd` needs a 68010+; there is
  no AttnFlags gate, so on a plain 68000 the vectors would trap.
- **`trapf`** (`0x51fc`, a 68020+ instruction) sits at code+0x1d2,
  between the dep-counter check and the ctor-stub calls of the
  open-all routine.  It never traps — effectively a 68020 NOP used
  as filler.  One of the seven hunk1-relocated longwords; reproduced
  raw.
- Deliberate **`illegal`** (`0x4afc`, also the Resident MatchWord
  value) at code+0x14c is the assert-failure target: `_check`
  `bsr`s into it.  The assert caller pushes the message string
  `"GEClass: Make GetFileImageClass failed !"` but nothing ever
  prints it — the string only exists because the assert macro once
  had a printf path.

## Hand-rolled setjmp/longjmp in LibInit

Init stores SP at bss+0x80 and a continuation pointer at bss+0x84.
Every `_openlib` failure clears bss+0x10 and `jmp`s through that
pointer, landing at 0x120 which restores the saved SP and runs the
cleanup.  So a missing exec/intuition/graphics/utility turns the
whole init into a single non-local return-0 — no unwinding loops,
just SP restore + latched cleanup.

## Compiler artifacts preserved verbatim

- `move.l #48,d2` (`0x243c 0000 0030`) instead of `moveq` — raw
  `.short`/`.long` emission needed since GAS canonicalises it.
- `pea 0xff:w` — pushes a bound as an absolute-word `pea`, not the
  usual `pea #imm`/`moveq` form (inside the strcmp call setup).
- Dead `addq.l #4,sp` adjusts right before `bra` to an epilogue that
  `unlk`s anyway (OM_NEW, IM_DRAW, default tails).
- `_dispose` does `push a0; push a0; pop a0` — a dead round trip.
- `sne (sp)-` materialises the MakeClass boolean as a stack byte for
  `_check`.
- `tst.b d0` after FreeClass whose result is ignored.
- Absolute `lea _bss:l` (6-byte `0x4xf9`) at every BSS touch — six
  sites, all in the hunk1 RELOC32 group; the two in `_init` are
  back-to-back (`lea _bss,a4; lea _bss,a1` for the clear loop).
- Datatab uses the 16-bit-offset InitStruct command forms
  (0xc000/0xd000/0xe000), so offsets carry a pad word.

## Relocation record order

The original's hunk0 self-relocation group is stored in **descending
nonstandard order** (`8a ba be c2 c6 ca ce b2 98 86 82 1a 16 12
a 6`) — not the ascending order a linker emits.  `fixup.py` rewrites
the RELOC32 section in this exact order after linking; hunk1 is
stored as pure `HUNK_BSS` (tag+END, no body) so fixup also drops the
zero body GNU ld emits for `.bss`.

## Behavioural quirks observed via the oracle

- **NULL-object short-circuit**: the `CallHook` trampoline returns 0
  when the object arg is NULL *without* invoking the superclass
  dispatcher, so `OM_NEW` with a NULL obj returns 0 silently.
- **iff.library is soft-optional**: missing iff.library only leaves
  the textfield class slot NULL; init still returns the lib base and
  every other function works.
- **Cleanup latch**: the dep-cleanup runs once (bit 0 of bss+0x88)
  even though it is reachable from both the init-fail path and
  Expunge — belt-and-braces against double free.
- **utility.library asked at v36** while the rest ask v33 — the only
  utility LVO actually called is `FindTagItem` (-30), twice, for the
  OM_NEW default-size checks.
- **`_check`'s 6-byte pop**: it pops two pushes (flag byte pad +
  string pointer) — matched to the `sne`/`pea` pair.
- IM_DRAW reads `dri+4` as the pen-array pointer (`dri_Pens`-style
  layout assumption) and indexes pens[6]/pens[2] directly.
- OM_NEW writes the 20x14 defaults straight into `im_Width`/`im_Height`
  at object +4/+6 (skipping the `Image` header at +0 — so the class
  assumes a `FrameI`-style layout where width/height sit at +4/+6).

## No defects found

The oracle produced identical 85-line logs for the original and the
rebuild across init (success + two failure modes), all six vectors,
OM_NEW (no-tags defaults, tag-supplied, NULL-obj, super-fail),
IM_DRAW (selected/unselected/no-drinfo pen paths), default-method
passthrough, name remapping, dispose, open/close, busy-expunge and
deferred-expunge-to-final-expunge.  No divergent behaviour or
original-vs-rebuild inconsistencies observed.
