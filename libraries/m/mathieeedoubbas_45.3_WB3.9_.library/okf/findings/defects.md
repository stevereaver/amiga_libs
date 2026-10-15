---
type: Finding
title: Quirks and defects
description: Behavioral quirks observed in the 45.3 combined build.
timestamp: 2026-10-15T16:40:00Z
---

# Quirks

## Functab selection (init @0x7a)

- Priority is `fpsp.resource` first: if OpenResource succeeds the
  68040 table @0x1cc wins **regardless of AttnFlags** — even on a
  machine that also has a real 68881 (attn&0x10).  Verified in the
  oracle: `init(fpsp=1, attn=0x10)` -> tabD.
- Without fpsp.resource the selector is a single `btst #4` on
  AttnFlags (0x129(a6)) — AFF_68881.  AFF_68882 (bit5) alone does
  NOT select the FPU table: `init(fpsp=0, attn=0x20)` -> tabB
  (software).  Slightly wrong for a 68882-only machine.
- A bare 68040 with no fpsp.resource gets the **software** table,
  not the FPU one — correct, since the FPU bodies use `fintrz`/`fint`
  which the 040 cannot execute natively.

## FPCR hook asymmetry -> IEEEDPFix rounding differs per flavour

init installs the FPCR-init open hook (fmove.l #0x90,fpcr: double
precision + round-to-zero) at lib+0x34 only when `AttnFlags&0x10`.
On the fpsp/040 path the hook stays the `clr.l d0;rts` stub, so
FPCR is left at its ambient value (0x00 = round-to-nearest in the
oracle).  Consequence observed in the logs:

- 68881 lib, post-open FPCR=0x90: `fix(1.5)=1`, `fix(42.9)=42` (RZ).
- fpsp/040 lib, FPCR=0x00: `fix(1.5)=2`, `fix(42.9)=43` (RN).

The 40.6 (040) sibling wrote FPCR=0x90 unconditionally in Open;
45.3 conditions the hook on a flag a real 040 never sets, so the
040 path keeps nearest-rounding for `fmove.l fp0,d0`.  (The real
68040 FPSP kernel also forces sane defaults, but nothing in this
lib does.)

## Vestigial flag at lib+0x22

`move.b (attn&0x10) -> lib+0x22` is written once by init and never
read anywhere in the module — dead state, presumably shared with
the companion mathieeedoubtrans build.

## Self-dispatch through the own vector table

- IEEEDPCeil @0x1f0 does `jsr -90(a6)` — calls whichever Floor the
  active functab bound — so Ceil is a single shared body and stays
  correct on all three flavours.
- The software floor helper does `jsr -66(a6)` (IEEEDPAdd via the
  vector slot, @0x28a) to subtract 1.0 — same self-dispatch idiom.

## Open never refuses; Close runs a no-op hook

- Open's hook (`jsr (a0)` on lib+0x34) may veto a call by returning
  nonzero, but both possible hooks always return 0.  Open also
  *clears* LIBF_DELEXP rather than refusing — opening a
  marked-for-deletion library silently unmarks it.
- Close invokes lib+0x38 (always the stub) and ignores the result —
  a hook slot with no user.

## Expunge: manual unlink, double free on re-entry

- The node is unlinked by hand (ln_Succ/ln_Pred splice); exec's
  Remove is never called.
- Calling Expunge again after a deferred expunge already ran
  (OpenCnt still 0) performs the unlink+FreeMem a second time —
  the oracle log shows two `freemem` entries per lib.  Harmless in
  real exec because a removed lib cannot be re-expunged, but the
  code has no guard.
- FreeMem gets its execbase from lib+0x28 (not a6 reload of $4) —
  the lib works even with a fake exec elsewhere.

## Binary quirks

- Entry stub returns -1 (`moveq #-1,d0` — the 040 sibling's returns 0).
- Reserved -24 vector is a dedicated `moveq #0,d0;rts` @0xf2, not an
  alias of the entry point.
- The RELOC32 group is stored non-sorted (`fc 7c 0a 1a 06 12 16`),
  suggesting hand-assembly/alignment rather than linker output;
  fixup.py preserves the order verbatim.
