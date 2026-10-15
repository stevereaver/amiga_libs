---
type: Finding
title: xpkNUKE_1.7 defects and quirks reproduced
timestamp: 2026-10-14T00:00:00Z
---

# Reproduced original defects / limits

- **40KB-of-zeros does not round-trip**: `z40k` packs (rc=0,
  outlen=8) but the stream references positions past the 16-bit
  `tab2` domain; the shipped decoder itself fails to expand it
  back (unpack rc=0 but bytes differ).  Inherited format limit,
  reproduced exactly.
- **PackFree return value**: returns `0x5c` — the d0 leftover of
  the final `FreeMem(w,92)` — when a workspace was cached, and the
  header is freed while `xsp_Sub[0]` still points at the freed block
  until the trailing `clrl a5@(52)`.  Reproduced: oracle shows
  `PackFree -> 5c`, `sub=0`.
- **Sentinel-candidate gate is `bls` (<=)**: a candidate `d6 <= d4`
  that produced a *better* match is discarded and ends the search.
  With `d4=0` this specifically rejects `d6=0` — position 0 is
  evaluated as a real chain candidate (its "match" would read bytes
  before the input), then thrown away.  Writing `<` instead
  diverges on `ramp`/`txt`/`rnd8k` (off-by-window-edge matches get
  emitted).
- **Sign-extended word adds** (`addaw`): `srcend = src +
  (SHORT)inlen` and `litptr = dst + (SHORT)outmax` truncate their
  size fields to 16 bits — inputs or outbufs >= 0x8000 wrap the
  pointer below the buffer (oracle stays under).
- **Short-input failure**: inputs that can't shrink return -17
  (XPKERR_EXPAND); `xsp_OutLen` still receives the attempted length.
  `empty/one/two/lit16/lit40/allb` all fail this way under the
  oracle's 0x8000 outbuf.
- **tiny-outbuf**: undersized OutBuf (e.g. 20) returns -17 with
  `xsp_OutLen = 0xffffffff` — the raw -1 of pack_core stored
  unfiltered at xsp+16.
- **Alloc failure**: PackChunk returns -7 when any of the three
  workmem AllocMems fail; XpksPackFree unwinds whichever of
  header/tab1/tab2 exist (verified: fail@1 frees hdr, fail@2 frees
  tab1+hdr).
- **Tables allocated uncleared**: pack_alloc asks for the tables
  with MEMF_NONE and relies on the wrapper's full memset each call —
  matching the original byte-for-byte on the allocmem/freemem trace.
- **No `$VER:` cookie** in the id string: `xpkNUKE 1.7
  (06.06.1997)\r\n` only.

# Notes on the trap instrumentation (methodology)

Early trap-based emit tracing was misleading: machine68k line-A
traps *replace* instructions, so hooking `movew a4@(40),d7`
(4 bytes) at 0x426 without re-setting N/Z made the following
`blts` use stale flags — the original then appeared to accumulate
`litcnt` forever.  Working harness (`work/trace_emit.py`,
`work/trace_chain.py`) emulates the trapped instruction *and* the
dependent conditional branch, redirecting pc past both.
