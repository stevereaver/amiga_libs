# iff.library 19.1 — vectors and ABI

All register conventions verified by disassembly + oracle.

## Lifecycle

### -6 LibOpen (a6=lib) → lib | 0
Walks the private MinList at lib+46 comparing node.task
(node+14) against `ExecBase->ThisTask` (read directly,
**no FindTask call** — new in 19.1).  Duplicate open by the
same task → returns **0** without touching opencnt.
On success: `AllocMem(22, MEMF_PUBLIC|MEMF_CLEAR)` (16.4
used no CLEAR), task stored at +14, AddTail, opencnt++,
`bclr #3, lib_Flags` (DELEXP now lives in the **real**
lib_Flags byte at +14 — 16.4 used a private word at +38).
Returns lib base in d0.

### -12 LibClose (a6=lib) → 0 | seglist
Finds this task's node; if found: Remove + FreeMem(22).
opencnt--; when it reaches 0 and lib_Flags bit 3 is set →
tail-calls LibExpunge (returns its seglist).

### -18 LibExpunge (a6=lib) → 0 | seglist
opencnt != 0 → `bset #3, lib_Flags` (+14), return 0.
Otherwise: Remove(lib node), CloseLibrary(DOSBase@38),
seglist from lib+42, `FreeMem(lib-negsize, neg+pos)`,
return seglist.

### -24 Reserved
Bare `rts` — d0 is whatever the caller left (16.4 returned
a clean 0).

## API

### -30 OpenIFF(name:a0, a6=lib) → handle
`moveq #-1,d6` then falls through into the NewOpenIFF
worker — autodetect memory attributes.

### -90 NewOpenIFF(name:a0, memattr:d0, a6=lib) → handle
dos.Open(name, MODE_OLDFILE) → err 16.  Reads the 12-byte
FORM header (result ignored); requires 'FORM' → err 19.
memattr < 0 → autodetect: 3 (CHIP) iff subtype is '8SVX'
else 1 (PUBLIC).  `AllocMem(12 + formsize, attr)` → err 18;
alloc size stored at node+0.  **Reads formsize-4 body
bytes into node+12** (16.4 read formsize — 4 bytes too
many).  Read() < 0 → err 17 and the node **leaks**; a short
positive read is accepted silently.  Header triple copied
to node+4.  Returns handle = node+4 (points at 'FORM').

### -36 CloseIFF(iff:a1, a6=lib) → 1
iff==0 → skip; else `FreeMem(iff-4, *(iff-4))` via cached
ExecBase.  Then clrerr → 1.

### -42 FindChunk(iff:a1, id:d0) → chunk ptr | 0 | end
Walks `iff+12` → `iff + 8 + formsize` (**exact** end — 16.4
scanned 4 bytes past).  First chunk header is tested
unconditionally, then step `8 + roundup2(chunksize)` while
`p < end`.  **id==0 returns the end pointer** (16.4
returned the first zero longword).  No error side-effects.

### -48 GetBMHD(iff:a1, a6=lib) → bmhd | 0
FindChunk('BMHD') + 8; missing → seterr(25).  Success →
clrerr (so a stale error is wiped).

### -54 GetColorTab(iff:a1, tab:a0, a6=lib) → count
FindChunk('CMAP'); absent → **return 0, no error**.
count = `divs.w` chunksize/3.  Each gun is masked `& 0xf0`
before packing → true 0x0RGB words
`(r&0xf0)<<4 | (g&0xf0) | (b&0xf0)>>4`.  16.4 OR'd the whole
bytes in (double-nibble corruption); **fixed**.

### -60 DecodePic(bm:a0, iff:a1, a6=lib) → 1 | 0
- iff+8 != 'ILBM' → err 24
- no BMHD → 0 (err 25 already stored by GetBMHD)
- **depth==0 → immediate success (clrerr, ret 1)** — new
- plane table: copies **24 longs** from bm+8 (reads 64
  bytes past bm_Planes[8] — enlarged from 16.4's 8)
- no BODY → err 26; comp 0→raw / 1→ByteRun1 / else err 28
- rowbytes = roundup2((w+15)>>3); rows = min(bm_Rows,
  bmhd.h) (signed compare)
- outer `dbcc` checks `src < end` **and** --rows != -1
  before each row → empty BODY writes nothing
- per row, per pic-plane i < bmhd.depth:
  `i < bm_Depth` → decode into planes[i] (advancing
  bm_BytesPerRow), else decode into a 400-byte **scratch
  row buffer** (new in 19.1 — extra planes discarded
  instead of error 27)
- masking==1 → one extra scratch decode per row
- success → clrerr, return 1

CmpByteRun1: `n>=0` → n+1 literals; `n<0` → `-n` replicate
only when `-n` is non-negative as a signed byte — **0x80 is
a proper NOP now** (16.4 emitted 129 copies).  Runs are
still not clipped at rowbytes.

### -66 SaveBitMap / -72 SaveClip → 1 | 0
Shared worker (SaveBitMap ≡ SaveClip x=0,y=0,w=BPR,h=Rows).
Same streaming scheme as 16.4: header written first with
FORM size 60±cmap, body streamed, then `Seek(0,BEGINNING)`
and the header + BODY chunk header rewritten.
- BMHD **left = x<<3, top = y** (new — 16.4 wrote 0,0)
- BMHD width = w<<3 (x/w still **byte** units)
- CAMG = calcmodes | (flags bit7 ? 0x800 HAM : 0); stored
  compression = flags & 0x7f
- CMAP: `depth==24 → treated as 8` (256 pens — new);
  csz = roundup4(3*ncol); absent ctab → -8 size adjustment
- body rows: `h` × `depth` × `w` bytes raw, or ByteRun1
  (unchanged encoder); padded to 4
- any short Write/Open failure → err 20

### -78 IFFError(a6=lib) → error
findnode; **no node → returns -1** (16.4 returned 0 — new
quirk).  Otherwise returns node+18 error and clears it.

### -84 GetViewModes(iff:a1, a6=lib) → modes
CAMG chunk present → `camg & 0xffff9efd` (new mask: strips
bits 0x0100|0x0200|0x1000|0x2000|0x4000|0x0002 — the
genlock/SUPERHIRES/private bits of the day).
Absent CAMG → GetBMHD (missing → 0 + err 25) then
depth<=4&&w>400 → 0x8000 HIRES; h>=320 → 0x0004 LACE;
depth>=6 → 0x0800 HAM (unchanged quirk: 6-plane
**half-brite** pictures still report HAM).

### -96 DecodeAnim(bm:a0, iff:a1, a6=lib) → 1 | 0  *NEW*
- iff+8 != 'ILBM' → err 24
- FindChunk('ANHD') missing → **err 29**
- `anhd[0] != 5` (operation byte) → err 28
- FindChunk('DLTA') missing → **err 30**
- builds `tab[i] = i*bpr` on the stack (2*bm_Rows bytes)
- for i in 0..bm_Depth-1: `off = ((ULONG*)(dlta+8))[i]`;
  `off != 0` → op5-decode `dlta+8+off` column-major into
  `bm_Planes[i]`; **offset 0 skips the plane entirely**
- success → clrerr, return 1

#### ANIM op-5 column format (per plane, per byte-column 0..bpr-1)
| op byte   | action |
|-----------|--------|
| 0         | next byte = count, next = value → replicate `count` bytes down the column (value repeated, addr += bpr) |
| 1..127    | skip `op` rows: `dst += tab[op]` |
| 0x80..0xff| literal: copy `op & 0x7f` bytes straight down the column |

The original decoder is Duff-unrolled ×8 on the column
stores; semantics identical to the reconstructed loop.
The op-5 layout is **column-major per byte-column** — a
"column" is the vertical strip of `bm_Rows` bytes at one
x-byte position.

## Error codes

| #  | Name    | Raised by |
|----|---------|-----------|
| 16 | OPEN    | dos.Open failed |
| 17 | READ    | body Read() < 0 (node leaks) |
| 18 | NOMEM   | AllocMem failed |
| 19 | NOTIFF  | first long != 'FORM' |
| 20 | WRITE   | save: Open/Write/Seek failure |
| 24 | NOILBM  | DecodePic/DecodeAnim on non-ILBM |
| 25 | NOBMHD  | GetBMHD/DecodePic/GetViewModes miss BMHD |
| 26 | NOBODY  | DecodePic misses BODY |
| 28 | COMPR   | DecodePic comp>1 / DecodeAnim op!=5 |
| 29 | NOANHD  | DecodeAnim misses ANHD — **new** |
| 30 | NODLTA  | DecodeAnim misses DLTA — **new** |

(16.4's 27=PLANES and the generic 19 for FindChunk
exhaustion are gone.)

## Exec/DOS LVOs used

Exec (via **cached** ExecBase@34 — 16.4 used abs $0004):
-198 AllocMem, -210 FreeMem, -246 AddTail, -252 Remove,
-408 OldOpenLibrary, -414 CloseLibrary.
The bootstrap additionally uses 4:w SysBase.
DOS (via DOSBase@38): -30 Open, -36 Close, -42 Read,
-48 Write, -60 Output, -66 Seek.
**FindTask (-294) and OpenLibrary (-552) are gone.**
No graphics.library or intuition.library calls anywhere.
