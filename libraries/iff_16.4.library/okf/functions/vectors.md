# iff.library 16.4 — vectors and ABI

All register conventions verified by disassembly + oracle.

## Lifecycle

### -6 LibOpen (a6=lib)
Returns lib in d0, or **0 if the calling task already holds an
open node** (FindTask match in the private list at lib+44).
On success: AllocMem(22), append node {task@14, err@18=0},
opencnt++, clear private DELEXP bit (lib+38 bit3).  Also
clears node error to 0 on entry.

### -12 LibClose (a6=lib)
findnode(FindTask(0)); if found, remove + FreeMem(22).
opencnt--; if 0 and private DELEXP set → tail-jump LibExpunge.

### -18 LibExpunge (a6=lib)
opencnt != 0 → `bset #3, lib+38` (delayed expunge, private
word), return 0.  Otherwise Remove, close DOSBase, compute
seglist = *(lib+34) >> 2, FreeMem(neg+pos area), return
seglist in d0.

### -24 Reserved
`moveq #0,d0; rts` — always returns 0.

## API

### -30 OpenIFF(name:a0, a6=lib) → handle
Shared worker with -90; memattr = autodetect: reads 12-byte
FORM header first, MEMF_CHIP if subtype `'8SVX'` else
MEMF_PUBLIC.  See NewOpenIFF.

### -90 NewOpenIFF(name:a0, memattr:d0, a6=lib) → handle
dos.Open(name, MODE_OLDFILE).  Reads 12-byte header
(result ignored — short reads accepted); requires 'FORM'.
AllocMem((formsize+4) & ~3, memattr); stores alloc size at
h-4; Read body into h (short reads accepted — on read
failure the node **leaks**).  Returns h = pointer to 'FORM'
longword, or 0 with error 16 (open) / 19 (not FORM) / 18
(nomem).

### -36 CloseIFF(handle:a1) → 1
`FreeMem(a1-4, *(a1-4))`.  NULL → returns 1 (no-op safe).

### -42 FindChunk(iff:a1, id:d0) → ptr
Walks from iff+16 (skips FORM tag/size/subtype) to
`iff + 8 + formsize` (i.e. `chunkstart + formsize` — see
defects: scans 4 bytes past real end).  Step = 8 + roundup2
(chunksize).  Returns pointer to matching chunk header (the
ID longword), or pointer to the longword containing 0 —
`FindChunk(iff, 0)` returns the first zero longword, the
documented end-of-FORM marker.  Sets error 19 if no match
before end? — no: sets error only via callers; itself writes
err=19 on exhausted scan without terminator.

### -48 GetBMHD(iff:a1) → bmhd ptr
`FindChunk(iff,'BMHD') + 8`, error 25 if absent.

### -54 GetColorTab(iff:a1, colortab:a0) → count
CMAP chunk triples → Amiga color words `(r>>4)<<8 | (g>>4)<<4
| (b>>4)`; count = cmapsize/3 (16-bit division).  Missing
CMAP → return 0 **without error** (err stays 0).

### -60 DecodePic(bitmap:a0, iff:a1, a6=lib) → 1/0
ILBM only (error 24 otherwise).  Requires BMHD (25) and BODY
(26); `nPlanes > bm_Depth` → 27; compression > 1 → 28.
Per plane/row: raw copy `rowbytes` (BPR) bytes, or ByteRun1
decode; `masking==1` decodes an extra row into a scratch
buffer after each row.  Plane pointers taken from
bm_Planes[0..nPlanes-1]; advance = bm_BytesPerRow.

### -66 SaveBitMap(name:a0, bitmap:a1, colortab:a2, flags:d0,
###     a6=lib) → 1/0
Shared save worker; clip params x=0,y=0,w=bitmap,h=bitmap.
Writes complete FORM/ILBM.  `flags` bit 0-6 = compression
byte stored as-is (any nonzero → ByteRun1 path); bit 7 →
CAMG.HAM + cleared from stored byte.  See codec.md.

### -72 SaveClip(name:a0, bitmap:a1, colortab:a2, flags:d0,
###     x:d1, y:d2, w:d3, h:d4, a6=lib) → 1/0
Same worker; **x and w are byte offsets/widths**, not pixels —
BMHD width written as `w*8`, body rows sliced
`plane + y*bpr + x .. +w`.

### -78 IFFError(a6=lib) → error
Reads the calling task's node error (offset +18) and clears
it.  No node → 0.

### -84 GetViewModes(iff:a1, a6=lib) → CAMG
CAMG chunk → its value.  Otherwise derive from BMHD
(error 25 if absent): width>400 && nPlanes<=4 → +HIRES
(0x8000); height>=320 → +LACE (4); nPlanes>=6 → +HAM (0x800)
— note half-brite pictures report as HAM.

## Error codes

| # | Name      | Raised by                        |
|---|-----------|----------------------------------|
|16 | OPEN      | dos.Open failed                  |
|17 | READ      | FORM body short read             |
|18 | NOMEM     | AllocMem failed                  |
|19 | NOTIFF    | not a FORM / FindChunk exhausted |
|20 | WRITE     | dos.Write short                  |
|24 | NOILBM    | DecodePic on non-ILBM            |
|25 | NOBMHD    | missing BMHD                     |
|26 | NOBODY    | missing BODY                     |
|27 | PLANES    | nPlanes > bm_Depth               |
|28 | COMPR     | compression > 1                  |
