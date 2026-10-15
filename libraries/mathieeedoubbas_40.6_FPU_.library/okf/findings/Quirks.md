---
type: Finding
title: Quirks
description: Oddities found in the shipped binary.
timestamp: 2026-10-10T23:00:00Z
---

# Quirks

- **Private DELEXP byte**: deferred-expunge state is bit3 of a
  private byte at base+0x2a — `lib_Flags`/`LIBF_DELEXP` never
  touched (same as the 40.6 singtrans build; AMIGALIBS-22).
- **Stack-shuffle FPU vectors**: doubles travel through the
  stack (fmoved sp@+/fop (sp)/fmoved fp0,(sp)); Add/Mul push
  both operands in one movem, Sub/Div push left first to keep
  operand order.  No FPU frame save — fp0 is caller-clobbered.
- **Integer-only Cmp/Tst/Abs/Neg**: IEEEDPCmp is a branch tree on
  bit patterns with +0==-0 handling and no NaN semantics; Tst is
  `add.l d0,d0` carry/magnitude; Abs `bclr #31`, Neg `bchg #31`
  (produces -0.0).
- **Open programs the FPCR**: `moveq #72/add.l d0,d0` ->
  `fmove.l d0,fpcr` sets 0x90 (double precision,
  round-to-zero) on every Open — the only sibling that does.
- **RT_ENDSKIP mid-module**: RomTag's rt_EndSkip == rt_Init ==
  hunk+0x7e, pointing at the InitTable itself rather than the
  end of the resident copy (same family trait as
  singtrans/mathtrans 40.6).
- **68020+68881 gate**: init fails without both — the code is
  68000-clean except this check (same quirk as singtrans 40.6).
- **ExtFunc → loader entry**: LVO -24 points at the module
  `moveq #0,d0; rts`, not a dedicated stub.
- No `$VER:`-style banner beyond the idstring; no trailing CRLF.
