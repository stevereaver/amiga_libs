---
type: Finding
title: xpkNUKE_1.8(000) quirks reproduced + 1.9 deltas
timestamp: 2026-10-15T00:00:00Z
---

# Deltas vs xpkNUKE_1.9 (all reproduced)

- **MEMF_ANY workspace alloc** (`AllocMem(196700, 0)` instead of
  MEMF_CLEAR) plus an explicit `clrl`x3 clear of the 12-byte scratch
  area at work+80 — alloc-path only.
- **Table clears on every call**: both hash tables are zeroed in the
  common path (not just on workspace reuse as in 1.9, which relied on
  MEMF_CLEAR for the first call).  Net effect identical; ordering
  preserved.
- **PackFree does not clear xsp_Sub[0]**: the stale workspace pointer
  survives; a later PackChunk reuses the freed block without any
  AllocMem (verified in the oracle — the post-free pack ran with an
  empty call log and still produced correct output since the stub
  pool never reclaims).
- **rt_EndSkip = 0** in the RomTag (1.9 pointed it at hunk end).
- **Seglist at lib+0x22** (34) — inside the 0x26-byte base, vs 1.9's
  +0x38.
- **Null vectors land on code+0** (the entry stub) via functab offset
  -0x98, not a separate LibNull routine.
- **Close/Expunge return via the code+0 stub** (`bnew 0x0`,
  `bras 0x0`) instead of a dedicated LibNull.
- **Descriptor fields differ**: xi_MasterVersion=2 (1.9: 0),
  xi_ModesVersion=0 (1.9: 1), xi_MinPkInChunk=0 (1.9: 10),
  xi_DefMode=100 (1.9: 50), xm_PackSpeed=0x1d (1.9: 0x24),
  xm_UnpackSpeed=0x1bf (1.9: 0x276); long name "Nuke V1.8".
- **`$VER:` cookie present** in the idstring (1.9 lacked it).
- **nlits tail formula**: `dst + sext(outmax) - litptr` computed at
  full width (addaw + suba.l), vs 1.9's `(dst-litptr)` with outmax
  added to the low word only — only the low word is ever used, so
  externally identical.
- Decoder is a compact earlier variant (no unrolled copy run); the
  shared nibble-extension block at 0x880 doubles as the 15-byte copy
  block entered mid-way via the jump table.

# Reproduced original defects / limits

- **40KB-of-zeros does not round-trip**: pack succeeds (rc=0,
  outlen=8) but the stream references positions past the 16-bit
  tab2 domain; the shipped decoder itself fails (match=False on the
  original).  Same format limit as 1.9.
- **Sign-extended word adds** (`addaw`) for `litptr` and `srcend`:
  OutBufLen or InLen >= 0x8000 wraps the pointer below the buffer.
- **Sentinel-candidate gate**: `cmp.w d4,d6; bls` — candidate 0 is
  rejected when d4=0; out-of-window candidates end the search.
- **Literal tail copy**: the copy loop is entered at its `dbf`
  (pre-decrement) — exactly `nlits.w` bytes.  (An earlier reading of
  a misaligned disasm suggested `nlits+1`; the correctly extracted
  hunk shows exact count.)
- **Short-input failure**: inputs below ~16 bytes return -17
  (XPKERR_EXPAND) with xsp_OutLen set to the attempted length.
- **tiny-outbuf**: undersized OutBuf returns -17 with
  xsp_OutLen=0xffffffff.
- **PackFree return**: whatever FreeMem leaves in d0 when a workspace
  exists; 0 when nothing cached.

# Earlier findings invalidated by the corrected hunk parse

The previous session's hunk extraction was misaligned by 8 bytes; its
claims of a partial 0x18000-byte tab1 clear and an `nlits+1` literal
copy were artefacts.  Re-parsed: tab1 is cleared fully
(0x2000-iteration x16B loop) and the literal tail copies exactly
nlits.w.
