# iff.library 16.4 — codec internals

## ByteRun1 decoder (+0x44e entry region)

Per output row of `rowbytes` = bm_BytesPerRow:

    for i = rowbytes-1 downto 0:          # dbf semantics
        if srclen-- == 0: break           # input exhausted
        n = *src++
        if n > 0x80:   # replicate: write (257-n) copies of *src++
        else:          # literal:    copy (n+1) bytes from src

Quirks (verified vs original):
- `0x80` is a **replicate** count (257-128 = 129 copies), not
  the standard NOP.
- Neither branch clips at `rowbytes` — a run or literal block
  overruns into the following output bytes.
- The input `srclen` guard only fires between output bytes;
  an overrun can read past the BODY end unchecked.
- Raw path (compression 0) enters mid-loop on the `dbf` →
  copies **exactly** `rowbytes` bytes.
- `masking==1`: after each decoded row an extra row is decoded
  into a stack/scratch row (mask plane consumed, discarded
  unless caller maps bm_Planes[nPlanes]).

## ByteRun1 encoder (+0x76a, used by save_crunch)

Two modes within a row:

- **Replicate run**: ≥3 equal bytes; emits `257-n`, byte;
  run capped at 128 bytes.
- **Literal**: accumulates differing bytes; emits `n-1`, data;
  capped at **127** bytes (`bmis` → `moveq #127,d2` — not 128).

## Save worker streaming (+0x492)

1. Build 268-byte stack header: 'FORM', placeholder size,
   'ILBM', 'BMHD', 20-byte BMHD (w/h from clip, depth from
   BitMap, masking=0, compression=flags&0x7f, pad/transp=0,
   aspect 0x0a0b, pagew/h=w/h), 'CAMG'+size+value,
   'CMAP'+size+triples (if colortab).
2. CAMG: helper +0x868 — if flag bit7 set → modes |= HAM
   (0x800) *and* compression byte's bit7 cleared; HIRES/LACE
   derived as in GetViewModes.
3. Open file (MODE_NEWFILE), Write the header.
4. Stream BODY: for each row y, for each plane: copy slice
   `plane + (y+clipy)*bpr + clipx, clipw` — raw Write or
   ByteRun1 into a row buffer first.
5. `Seek(fh, 0, OFFSET_BEGINNING)` — rewind, rewrite the
   60-ish-byte header with the real FORM size patched in.
   The 'BODY'+size longwords are **written after** the body
   data via a second seek — the file ends up correct.

Note: CMAP stored as RGB triples (colortab words expanded to
8-bit components by `<<4 |` replication).

## Internal helpers

- **+0x7dc findnode(lib:a6, task:d0→a0)**: walk lib+44 list,
  match node+14 == FindTask(0).  Returns node or 0.
- **+0x7fc clrerr**: node->err(+18) = 0 for caller's task.
- **+0x808 seterr(d0)**: node->err(+18) = d0.
- **+0x868 CalcViewModes(bmhd:a0)**: CAMG derivation shared
  by SaveBitMap and GetViewModes.
