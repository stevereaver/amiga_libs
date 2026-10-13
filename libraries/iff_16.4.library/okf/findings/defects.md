# iff.library 16.4 — defects and quirks (all reproduced)

## ByteRun1 decoder

- **`0x80` is not a NOP.** The decoder's signed test routes
  0x80 to the replicate branch: 257-128 = **129 copies**.
  Standard EA IFF says NOP.  Any compliant file using
  0x80-NOP decodes corrupted here.
- **Runs not clipped at rowbytes.** A replicate or literal
  run spills past the output row into subsequent plane bytes.
- **Input-end check only between bytes.** An in-flight run
  reads past the BODY end unchecked.
- Raw decoder entry is mid-`dbf`-loop → copies **exactly**
  rowbytes bytes (initially mis-reconstructed as rowbytes+1).

## OpenIFF / loading

- The 12-byte header `Read()` result is ignored — a short
  read leaves a garbage FORM size that is then trusted.
- A short FORM-body `Read()` sets error 17 but the allocated
  node is **leaked** (not freed on the error path).
- Alloc size `(formsize+4)&~3` rounds to 4 bytes, not the
  usual 2.

## FindChunk

- Scan bound is `chunkstart + formsize`, but formsize already
  includes the 4-byte subtype — the walker effectively
  overruns **4 bytes past** the real chunk area into whatever
  follows the last chunk in memory.
- `FindChunk(iff, 0)` returns the first zero longword —
  functions as an end-of-FORM marker only because heap bytes
  happen to be zero.

## DecodePic

- ILBM only — rejects other FORM types with error 24 even
  though the BODY layout would apply.
- Compression byte: raw only if 0, ByteRun1 only if 1,
  anything else → error 28.  Nonstandard comp values 2..127
  (e.g. a steganographic "HAM" flag misuse) rejected.

## GetViewModes

- `nPlanes >= 6 → HAM` — 6-plane **half-brite** pictures are
  misreported as HAM.
- HIRES only when width>400 *and* depth<=4 (a 640×200 5-plane
  image gets neither HIRES nor HAM).
- Missing CAMG *and* BMHD → returns 0 + error 25.

## GetColorTab

- Absent CMAP returns 0 with **no error set** — callers
  cannot distinguish "no palette" from "empty palette".

## SaveBitMap / SaveClip

- SaveClip x/w are **byte** units (BMHD width = w*8) — an
  easy caller footgun inconsistent with pixel intuition.
- Streaming trick: seeks back to 0 after writing the body and
  rewrites the header + writes the BODY chunk header after
  the data.  Works, but leaves the file briefly inconsistent
  and fails on non-seekable outputs.
- flags bit7 doubles as "set HAM" (stored comp byte loses
  bit7); compression values >1 stored verbatim.
- Literal-run cap is 127 (not 128) — one byte shy of the
  ByteRun1 maximum.

## Lifecycle

- LibOpen **rejects a second open by the same task** — the
  per-task node list doubles as an open-once gate (documented
  by the author as intentional).
- Delayed-expunge flag lives at lib+38 bit3 (private word),
  not the standard lib_Flags DELEXP — a foreign Expunge
  scanner would miss it.
- Reserved vector -24 returns 0 (nonstandard; most libs
  return non-zero or the lib base).
