# support.library 1.2 — vector map

Functab: 18 absolute-long entries at code+0xc4 (LVOs -6..-108), `-1`
terminated at +0x10c.  Register ABI: lib base in a6; buffer args in
a0/a1; counts in d0-d2; -30 uses a0-a3 as out-pointers; -102 takes a
caller-supplied **mathffp.library** base in a4.

## Resident/init

- **Packed RomTag @ code+0x66**: `4afc` + unaligned longs
  {matchtag→+0x66, endskip→hunk end (+0x7f0), flags=0x80 AUTOINIT,
  ver=1, type=9, pri=0, name→+0x80, idstr→+0x90, init→+0xb4}.
- **InitTable @ +0xb4**: `{dsize=0x2a (42), functab→+0xc4,
  datatab→+0x110, initfn→+0x13c}`.
- **datatab @ +0x110** (InitStruct): byte +8=9 (ln_Type), long +10→name,
  byte +14=6 (ln_Flags), long +20=0x00030004 (lib_Version=3,
  lib_Revision=4 — see defects).  lib+24 idstr is never set (stays 0).
- **initfn @ +0x13c** `(d0=lib→a4, a0=seglist, a6=execbase)`:
  seglist→lib+34; `OpenLibrary("dos.library",37)`→lib+38; returns lib
  (or 0 if the open failed — d0 residue of the failed call).
- **Open** (-6, +0x162): `bclr #3,lib+14`; OpenCnt.w++; returns a6.
- **Close** (-12, +0x170): `d0=0`; OpenCnt--; if 0 and flag3 → bsr
  expunge (returns its seglist).
- **Expunge** (-18, +0x184): OpenCnt!=0 → `bset #3,lib+14`, ret 0.
  Else CloseLibrary(lib+38), Remove(lib), seg=lib+34,
  FreeMem(lib−NegSize, Neg+Pos=150), return seg.
- **-24 stub** (+0x1ca): `moveq #0,d0; rts`.

## Public functions

### SnapSize (-30, +0x1ce) `(d0 w, d1 h, d2 mode, d3 flag, a0 *op, a1 *oh, a2 wh2, a3 *ctr)`

Two-pass resolution snapper.  Each pass re-bases `*ctr` to
`0x40020050` (mode==3) or `0x40020020` (mode!=3), then runs a test
ladder (signed word compares on w,h):

```
320x240  (no ++)          fail -> ++ctr
640x480                   fail -> ++ctr
mode==3:  768x576 -> ++ctr,set    else set 800x600 unconditionally
mode!=3:  800x600                 fail -> ++ctr
1024x768                  fail -> ++ctr
1120x832                  fail -> ++ctr
1152x900                  fail -> ++ctr
1280x1024                 fail -> ++ctr
1600x1200 (unconditional)
```

Then (LAB_001D) if `mode==3 && flag != 0x200000`: writes WORD 600 at
`*op+2` and 480 at `*oh+2` (low-word overwrite of the longs).  Then
clamps: `if(*op < w) *op = w; if(*oh < h) *oh = h` (LONG compares).

Pass counter d4 (word): after 2 passes return.  Otherwise loads
`w=wh2[0], h=wh2[1]` (word loads); h==0 → return.  If
`(short)(*op - w2) < 0` or `(short)(*oh - h2) < 0` → repick (16-bit
compares on the *long* results).  If the second pair already fits,
a2's pair is re-classified into the shared scratch long at
code+0x700 — with a0==a1 both pointing at the same longword, so the
h-pick overwrites the w-pick.

d0 residue = current working w (w2 on the second pass, 0 when h2==0).

### Channel clears (-36/-42/-48/-54, +0x352/+0x36e/+0x394/+0x3ae)

`(a0 buf, d0 rowlen, d1 total)`.  Row-interleaved: three byte rows
per pixel row.  Each writes `0`-longs (4 bytes per store!) stepping
`c -= 2` or `c -= 4` per long over one row of a triple:

- Keep0 (start buf+rowlen): inner `movel #0,(a0)+; subq.l#2,d0` —
  writes 2*rowlen bytes in one pass = clears rows 1+2 of the triple;
  then `a0 += rowlen`; total `-= 3*rowlen`.
- Keep1 (start buf): two inner loops of `subq.l#4` over rows 0 and 2.
- Keep2 (start buf): `subq.l#2` over rows 0+1, then `a0 += rowlen`.
- Clear2 (start buf+2*rowlen): `subq.l#4` over row 2 only;
  `a0 += 2*rowlen`.
- All loops are do-while and overrun for tiny/odd rowlens.
- d0 residue = rowlen.

### Invert (-60, +0x3ce)

`(a0, d0 n)`: `d1.b = 0xff - *p; *p++ = d1.b; subq.l#1,d0; bne`.
n=0 wraps to -1 → ~4G iterations (hangs).  d0 residue = 0.

### Gray (-66, +0x3de)

`(a0, d0 triples, d1 cols)`.  Per column: `v = p[0]/3 + p[c]/3 +
p[2c]/3` (byte divides — NOT the true mean, see defects); stores v to
all three rows.  Inner counter d7 is 16-bit DBF; the outer counter
(d0) is tested *inside* the column loop, so the last triple runs one
extra column before the `beq` exits.  d0 residue = 0.

### Scanline (-72, +0x442)

`(a0, d0 rowlen, d1 total)`: clears rows 3-5 of every 6*rowlen block
(two clear loops `subq.l#2` + `subq.l#4`), `a0 += 3*rowlen`,
`total -= 6*rowlen`.  d0 residue = rowlen.

### Dither (-78, +0x46e)

`(a0, d0 n)`: `*p++ = 0; p++; c -= 2` until c<=0 — clears every other
byte (first byte of each pair).  d0 residue = final c.

### Swap3 (-84, +0x47a)

`(a0, d0 n)`: walks triples from both ends (`b` forward, `e` back);
front gets back's reversed triple and vice versa (mirror + R<->B in
one pass).  `c = n>>1; c -= 3` per iter until <=0.  Overlaps on
non-multiple-of-6 lengths are as shipped.  d0 residue = final c.

### Mirror (-90, +0x4be)

`(a0, d0 width, d1 pixel-rows)`: reverses `3*d1` byte rows in place,
w/2 swaps per row via 16-bit DBF.  Front/back pointers are carried
between rows (`bk += width + w/2`, `f += w/2`), so odd widths drift
one byte per row.  d0 residue = (w>>1)-1.

### SwapRB (-96, +0x4f4)

`(a0, d0 rowlen, d2 total)`: swaps row0<->row2 longs of each triple
(`subq.l#4` inner, `a0/a1 += 2*rowlen`, `total -= 3*rowlen`).
d0 residue = rowlen.

### Mosaic (-102, +0x520)

`(a0 src, d0 w, d1 h, a4 mathffpbase)`.  10x10 block average in place
over w x h pixels (3*h byte rows of w bytes).  Uses scratch at
code+0x700: s[0]=w, s[1]=w/10-1 (full col blocks-1), s[2]=w%10,
s[4]=h/10-1, s[5]=h%10, s[11]=w-10 (row-skip).  Per block: sums three
channel rows (10 rows x 10 cols each), mean per channel =
`SPFix(SPDiv(SPFlt(sum),SPFlt(100)))` via the a4 base (SPFlt -36,
SPDiv -84, SPFix -30), writes the mean over all 3x100 bytes of the
block.  Column loop d2 / row loop d5 are 16-bit DBF; remainder columns
(s[2]) are skipped, remainder rows ignored.  d0 residue = w*30.

### Transpose (-108, +0x68c)

`(a0 src, a1 dst, d0 w, d1 h)`.  Scatters a row-interleaved region to
per-column channel planes: for each column c (w cols, 16-bit DBF):
writes h bytes `dst[c][0..h)=row0`, `dst[h..2h)=row1`,
`dst[2h..3h)=row2` — i.e. dst[c*3h + chan*h + r] = src[r*3w + chan*w +
c].  Also stashes {dst,src,w,h} into scratch s[0..3] (visible but
unused read-back).  d0 residue = h.

## Dead code

- **code+0** (+0x00..+0x37): a banner-print routine nothing calls —
  `OpenLibrary("dos.library",0)`, `Output()`(-60),
  `Write(fh, banner, 46)`(-48), `CloseLibrary`, return 0.
  Banner at +0x38: `"\nsupport.library v1.2 (13.03.) © 1996 by T&T\n\n"`.

## External calls

- exec: OpenLibrary -552, CloseLibrary -414, Remove -252, FreeMem -210
- dos: Output -60, Write -48 (dead banner only)
- mathffp: SPFlt -36, SPDiv -84, SPFix -30 (through a4, -102 only)
