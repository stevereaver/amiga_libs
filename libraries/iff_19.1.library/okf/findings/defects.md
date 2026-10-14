# iff.library 19.1 — defects and quirks (all reproduced)

## Fixed since 16.4

- **ByteRun1 `0x80` is a real NOP now.**  16.4 treated it
  as a replicate op and emitted **129 copies** of the next
  byte; 19.1's signed-negation path drops it cleanly.
  Verified by the oracle's RLE fixture (a NOP mid-stream
  produces identical output on original and rebuild).
- **GetColorTab produces true 0x0RGB words.**  Each gun is
  masked `& 0xf0` before packing; 16.4 OR'd full bytes.
- **OpenIFF reads formsize-4 body bytes** — 16.4 over-read
  by 4.
- **FindChunk scan bound is exact** (`iff+8+formsize`) —
  16.4 overshot by 4 bytes.  And `FindChunk(iff,0)` now
  returns the end pointer *unconditionally* (16.4 hunted
  for a zero longword).
- **Extra planes decode instead of erroring.**  16.4's
  ERR_PLANES(27) is gone: planes beyond bm_Depth decode
  into a 400-byte scratch row buffer.  Rows are also
  clamped to `min(bm_Rows, bmhd.height)`.
- **GetViewModes masks CAMG** with `0xffff9efd` instead of
  returning the raw long.
- **SaveClip writes real BMHD left/top** (`x*8`, `y`) —
  16.4 wrote 0,0.
- **ExecBase is cached in lib data** (+34) and used for all
  exec calls; `4:w` absolute loads and FindTask are gone.
- **Delayed expunge uses the real LIBF_DELEXP bit**
  (lib_Flags +14 bit 3) instead of a private flag word.
- **LibOpen allocates the task node with MEMF_CLEAR.**

## Still present (inherited quirks)

- **Short reads accepted.**  The 12-byte FORM header read
  and the formsize-4 body read only fail when Read() < 0;
  a truncated file returns a valid-looking handle whose
  tail is uninitialised heap.  Verified: `short.iff`
  (claims 400, contains 8) → handle + err 0.
- **Leaked node on body-read failure** — AllocMem is never
  freed on the err-17 path (untestable in practice: Read
  errors are rare).
- **IFFError drains the node error** — second call returns
  0 (or -1, see below).
- **Duplicate LibOpen by the same task fails** (returns 0)
  — unchanged.
- **FindChunk checks the first chunk header before any
  bounds check** — on a degenerate FORM it can read past
  the end.
- **ByteRun1 runs are not clipped at rowbytes** — a long
  replicate/literal spills into the next plane row.
- **SaveClip x/w are byte units** (BMHD width = w*8) and
  the body is sliced `plane + y*bpr + x .. +w` — still a
  caller footgun.
- **Save worker streams then seeks back** to rewrite FORM
  size + BODY header — fails on non-seekable handles.
- **flags bit7 doubles as HAM marker** in Save calls and is
  stripped (`& 0x7f`) from the stored compression byte.
- **Literal-run cap is 127** in the encoder, one short of
  the ByteRun1 max.
- **depth>=6 → HAM** in derived view modes — half-brite
  pictures still misreport.
- **GetColorTab returns 0 without error** on missing CMAP
  (indistinguishable from an empty palette).

## New in 19.1

- **IFFError returns -1** when the calling task holds no
  open node (16.4 returned 0).  Any caller that treats a
  task-less IFFError as "no error" now sees -1.
- **Reserved vector returns garbage** — bare `rts`, d0 is
  caller-supplied residue (16.4 did `moveq #0`).
- **DecodePic/DecodeAnim copy 24 plane pointers** from
  bm+8 — reading 64 bytes past `bm_Planes[8]`.  Harmless
  in practice (only bm_Depth/pic-depth entries are used)
  but technically an out-of-structure read.
- **DecodePic depth==0 short-circuits success** without
  requiring BODY.
- **DecodeAnim**: DLTA plane offsets of 0 leave the plane
  untouched (implicit "keep previous frame").  Rows beyond
  the stream's writes are untouched as well — the caller's
  plane memory shows through, exactly like the hardware
  anim players expect.
- **anim5 literal op is `op & 0x7f`** — opcodes 0x80..0xff
  mean 1..127 literals, i.e. the count is NOT `-op` as the
  classic spec's wording suggests (0xFE = -2 → **126**
  literals, not 2).  Files generated for the spec's
  "-n literals" encoding decode wrongly.
- **No ERR_PLANES (27) anymore** — but a pic plane decoded
  to scratch can still emit garbage silently.
