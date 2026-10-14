---
type: Finding
title: xpkNUKE_1.9 quirks reproduced
timestamp: 2026-10-14T00:00:00Z
---

# Reproduced original defects / limits

- **40KB-of-zeros does not round-trip**: pack succeeds (rc=0,
  outlen=8) but the emitted stream references a position past the
  16-bit `tab2` domain; the shipped decoder itself fails to expand it
  back (match=False in the oracle on the *original* binary).
  Reconstruction reproduces this exactly — it is a format limit, not
  a reconstruction bug.
- **Sign-extended word adds** (`addaw`) for `litptr` and `srcend`:
  `OutBufLen` or `InLen` >= 0x8000 wraps the pointer below the
  buffer.  The oracle keeps OutBufLen=0x8000 where the original
  still works.
- **Sentinel-candidate gate**: `cmp.w d4,d6; bls` — candidate 0 (the
  empty-chain sentinel) *can* reach the compare loop and even
  produce a very long match, but `d6<=d4` (with d4=0 inside the
  window) rejects it.  Trap-based tracing that replaced the
  conditional branches corrupted flags and made the original appear
  to accept it — raw objdump + careful trap placement settled it.
- **`nlits` low-word add**: `(dst - litptr) +w outmax` — only the low
  16 bits get outmax added; the pad loop uses the full long, the copy
  loop uses the low word.
- **Literal copy count**: the tail copy loop is entered at its
  `subqw` (pre-decrement), so it copies exactly `nlits.w` bytes — an
  earlier `+1` reading of the disasm was wrong.
- **PackFree return**: returns whatever FreeMem leaves in d0 when a
  workspace exists; 0 only when nothing was cached.
- **Short-input failure**: inputs below ~16 bytes always return -17
  (XPKERR_EXPAND) with xsp_OutLen still set to the attempted length.
- **tiny-outbuf**: undersized OutBuf returns -17 with
  xsp_OutLen=0xffffffff.
