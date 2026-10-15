/*
**	support.c -- support.library 1.2 (11 Januar 96) by Thomas Wenzel (T&T)
**
**	C reconstruction of the shipped single-hunk binary (2200 bytes).
**	AUTOINIT packed RomTag at code+0x66 (not longword aligned);
**	InitTable at +0xb4 {dsize=42, functab@+0xc4, datatab@+0x110,
**	initfn@+0x13c}; shared scratch block at code+0x700; dead
**	banner-print routine at code+0.
**
**	All public entries use the original register ABI (args in
**	d0-d3/a0-a3, lib base in a6, mathffp base in a4 for -102);
**	the .s stubs marshal arguments for the C bodies.
**
**	The image helpers operate on row-interleaved RGB data: each
**	pixel row is stored as three consecutive byte rows (R,G,B),
**	so a "row triple" spans 3*rowlen bytes.
**
**	Vectors:
**	    -6   Open      -12  Close      -18  Expunge     -24  null stub
**	    -30  SnapSize(d0 w, d1 h, d2 mode, d3 flag, a0 pw, a1 ph,
**	                  a2 wh2, a3 ctr)
**	    -36  Keep0(a0,d0,d1)      clear chans 1,2 of each triple
**	    -42  Keep1(a0,d0,d1)      clear chans 0,2
**	    -48  Keep2(a0,d0,d1)      clear chans 0,1
**	    -54  Clear2(a0,d0,d1)     clear chan 2 only
**	    -60  Invert(a0,d0)        b = 255-b over d0 bytes
**	    -66  Gray(a0,d0,d1)       per-column (R,G,B) -> mean
**	    -72  Scanline(a0,d0,d1)   clear every other row triple
**	    -78  Dither(a0,d0)        clear every other byte
**	    -84  Swap3(a0,d0)         mirror + per-triple byte reverse
**	    -90  Mirror(a0,d0,d1)     reverse each byte row (3*d1 rows)
**	    -96  SwapRB(a0,d0,d2)     swap chan 0/chan 2 rows
**	    -102 Mosaic(a0,d0,d1,a4=mathffp)   10x10 block average in place
**	    -108 Transpose(a0 src, a1 dst, d0 w, d1 h)
**
**	Defects / quirks preserved (see okf/findings/defects.md):
**	  - code+0 banner routine is dead code (nothing calls it).
**	  - datatab initialises lib_Version=3 / lib_Revision=4 while the
**	    id string and RomTag both say 1.2 / version 1.
**	  - -24 is a real `moveq #0,d0; rts` routine, not a NULL vector.
**	  - -30 SnapSize compares w/h as signed words; *ctr is re-based to
**	    0x40020050 (mode 3) / 0x40020020 (other) on every pass and
**	    bumped once per failed test, so it ends as magic|index.
**	  - the clear loops are do-while: a zero/short count still writes
**	    at least one long, overrunning the nominal region.
**	  - -60 Invert loops while d0 != 0 after decrement: d0=0 wraps to
**	    -1 and runs ~4 billion iterations (effectively hangs).
**	  - -66 Gray tests the row counter inside the column loop and
**	    processes one column too many on the final row triple.
**	  - -90 Mirror's row advance uses 2*(w/2) instead of w, drifting
**	    one byte for odd row widths.
**	  - -102 Mosaic calls mathffp.library vectors (SPFlt -36,
**	    SPDiv -84, SPFix -30) through a4, which the library never
**	    opens itself -- callers must pass mathffpbase in a4.
*/

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef long           LONG;
typedef void          *APTR;

#define LIBBASE_DOS  38		/* struct Library +34 seglist, +38 dos */

/* code+0x700 scratch region (defined in support_lib.s) */
extern ULONG sup_scratch[];

/* ------------------------------------------------------------------ */
/* exec/dos primitives (same idiom as the other T&T reconstructions)   */

static APTR openlib(const char *name, ULONG ver)
{
	register ULONG d0 __asm("d0") = ver;
	register APTR  a1 __asm("a1") = (APTR)name;
	register APTR  a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-552)"
			: "+r"(d0) : "r"(a1), "r"(a6));
	return (APTR)d0;
}

static void closelib(APTR lib)
{
	register APTR a1 __asm("a1") = lib;
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-414)" :: "r"(a1), "r"(a6));
}

static void removelib(APTR lib)
{
	register APTR a1 __asm("a1") = lib;
	register APTR a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-252)" :: "r"(a1), "r"(a6));
}

static void freemem(APTR p, ULONG size)
{
	register APTR  a1 __asm("a1") = p;
	register ULONG d0 __asm("d0") = size;
	register APTR  a6 __asm("a6") = *(APTR *)4;
	__asm volatile ("jsr a6@(-210)" :: "r"(a1), "r"(d0), "r"(a6));
}

/* mathffp primitives: a6 = mathffpbase (arrives in a4 at the -102 entry) */
static ULONG mf_flt(APTR mffp, ULONG v)			/* SPFlt -36 */
{
	register ULONG d0 __asm("d0") = v;
	register APTR  a6 __asm("a6") = mffp;
	__asm volatile ("jsr a6@(-36)" : "+r"(d0) : "r"(a6));
	return d0;
}

static ULONG mf_div(APTR mffp, ULONG num, ULONG den)	/* SPDiv -84 */
{
	register ULONG d0 __asm("d0") = num;
	register ULONG d1 __asm("d1") = den;
	register APTR  a6 __asm("a6") = mffp;
	__asm volatile ("jsr a6@(-84)" : "+r"(d0) : "r"(d1), "r"(a6));
	return d0;
}

static ULONG mf_fix(APTR mffp, ULONG v)			/* SPFix -30 */
{
	register ULONG d0 __asm("d0") = v;
	register APTR  a6 __asm("a6") = mffp;
	__asm volatile ("jsr a6@(-30)" : "+r"(d0) : "r"(a6));
	return d0;
}

/* ------------------------------------------------------------------ */
/* init / open / close / expunge                                      */

/* initfn: exec AUTOINIT entry -- d0=lib, a0=seglist, a6=execbase.
   Stores seglist at lib+34, opens dos.library v37 into lib+38. */
APTR sup_init(APTR lib, APTR seglist)
{
	*(APTR *)((UBYTE *)lib + 34) = seglist;
	*(APTR *)((UBYTE *)lib + LIBBASE_DOS) = openlib("dos.library", 37);
	if (!*(APTR *)((UBYTE *)lib + LIBBASE_DOS))
		return 0;
	return lib;
}

APTR sup_open_body(APTR lib)
{
	((UBYTE *)lib)[14] &= ~8;		/* LIBF_DELEXP */
	(*(UWORD *)((UBYTE *)lib + 32))++;
	return lib;
}

APTR sup_close_body(APTR lib);			/* fwd */

static APTR sup_expunge(APTR lib)
{
	APTR seglist;
	ULONG sz;
	if (*(UWORD *)((UBYTE *)lib + 32)) {
		((UBYTE *)lib)[14] |= 8;
		return 0;
	}
	closelib(*(APTR *)((UBYTE *)lib + LIBBASE_DOS));
	removelib(lib);
	seglist = *(APTR *)((UBYTE *)lib + 34);
	sz = *(UWORD *)((UBYTE *)lib + 16);
	freemem((UBYTE *)lib - sz,
		sz + *(UWORD *)((UBYTE *)lib + 18));
	return seglist;
}

APTR sup_close_body(APTR lib)
{
	if (!--*(UWORD *)((UBYTE *)lib + 32) &&
	    (((UBYTE *)lib)[14] & 8))
		return sup_expunge(lib);
	return 0;
}

APTR sup_expunge_body(APTR lib)
{
	return sup_expunge(lib);
}

/* ------------------------------------------------------------------ */
/* -30 SnapSize -- snap (w,h) to the smallest standard resolution      */
/* >= the request; then repeat for a second (word) pair at a2,         */
/* discarding into scratch when the first answer already fits.         */

ULONG sup_snap_body(ULONG w, ULONG h, ULONG mode, ULONG flag,
	      ULONG *pw, ULONG *ph, UWORD *wh2, ULONG *ctr)
{
	ULONG *op = pw, *oh = ph;
	UWORD pass = 0;

	for (;;) {
		*ctr = 0x40020050UL;
		if (mode != 3)
			*ctr = 0x40020020UL;
		if ((short)w <= 320 && (short)h <= 240) {
			*op = 320; *oh = 240;
			goto fin;
		}
		(*ctr)++;
		if ((short)w <= 640 && (short)h <= 480) {
			*op = 640; *oh = 480;
			goto fin;
		}
		(*ctr)++;
		if (mode == 3) {
			if ((short)w <= 768 && (short)h <= 576) {
				(*ctr)++;
				*op = 768; *oh = 576;
				goto fin;
			}
			*op = 800; *oh = 600;
			goto fin;
		}
		if ((short)w <= 800 && (short)h <= 600) {
			*op = 800; *oh = 600;
			goto fin;
		}
		(*ctr)++;
		if ((short)w <= 1024 && (short)h <= 768) {
			*op = 1024; *oh = 768;
			goto fin;
		}
		(*ctr)++;
		if ((short)w <= 1120 && (short)h <= 832) {
			*op = 1120; *oh = 832;
			goto fin;
		}
		(*ctr)++;
		if ((short)w <= 1152 && (short)h <= 900) {
			*op = 1152; *oh = 900;
			goto fin;
		}
		(*ctr)++;
		if ((short)w <= 1280 && (short)h <= 1024) {
			*op = 1280; *oh = 1024;
			goto fin;
		}
		(*ctr)++;
		*op = 1600; *oh = 1200;
	fin:
		if (mode == 3 && flag != 0x200000UL) {
			((UWORD *)op)[1] = 600;
			((UWORD *)oh)[1] = 480;
		}
		if ((long)*op - (long)w < 0)
			*op = w;
		if ((long)*oh - (long)h < 0)
			*oh = h;
		if (++pass == 2)
			return w;
		w = wh2[0];
		h = wh2[1];
		if (h == 0)
			return w;
		if ((short)((UWORD)*op - (UWORD)w) < 0)
			continue;
		if ((short)((UWORD)*oh - (UWORD)h) < 0)
			continue;
		op = sup_scratch;	/* both ptrs -> same scratch long */
		oh = sup_scratch;
	}
}

/* ------------------------------------------------------------------ */
/* channel clears -- buffers are 3*rowlen blocks, rowlen = d0,         */
/* total byte count = d1.  All loops are do-while like the original.   */

/* -36 Keep0: keep row 0 of each triple, clear rows 1,2 */
ULONG sup_keep0_body(UBYTE *buf, ULONG rowlen, ULONG total)
{
	ULONG *p = (ULONG *)(buf + rowlen);
	LONG t = (LONG)total;
	do {
		LONG c = (LONG)rowlen;
		do {
			*p++ = 0;
			c -= 2;
		} while (c > 0);
		p = (ULONG *)((UBYTE *)p + rowlen);
		t -= 3 * (LONG)rowlen;
	} while (t > 0);
	return rowlen;			/* d0 residue */
}

/* -42 Keep1: keep row 1, clear rows 0 and 2 */
ULONG sup_keep1_body(UBYTE *buf, ULONG rowlen, ULONG total)
{
	ULONG *p = (ULONG *)buf;
	LONG t = (LONG)total;
	do {
		LONG c = (LONG)rowlen;
		do {
			*p++ = 0;
			c -= 4;
		} while (c > 0);
		p = (ULONG *)((UBYTE *)p + rowlen);
		c = (LONG)rowlen;
		do {
			*p++ = 0;
			c -= 4;
		} while (c > 0);
		t -= 3 * (LONG)rowlen;
	} while (t > 0);
	return rowlen;
}

/* -48 Keep2: keep row 2, clear rows 0,1 */
ULONG sup_keep2_body(UBYTE *buf, ULONG rowlen, ULONG total)
{
	ULONG *p = (ULONG *)buf;
	LONG t = (LONG)total;
	do {
		LONG c = (LONG)rowlen;
		do {
			*p++ = 0;
			c -= 2;
		} while (c > 0);
		p = (ULONG *)((UBYTE *)p + rowlen);
		t -= 3 * (LONG)rowlen;
	} while (t > 0);
	return rowlen;
}

/* -54 Clear2: clear only row 2 of each triple */
ULONG sup_clear2_body(UBYTE *buf, ULONG rowlen, ULONG total)
{
	ULONG *p = (ULONG *)(buf + 2 * rowlen);
	LONG t = (LONG)total;
	for (;;) {
		LONG c = (LONG)rowlen;
		do {
			*p++ = 0;
			c -= 4;
		} while (c > 0);
		p = (ULONG *)((UBYTE *)p + 2 * rowlen);
		t -= 3 * (LONG)rowlen;
		if (t <= 0)
			return rowlen;
	}
}

/* -60 Invert: b = 255 - b over d0 bytes (d0=0 wraps -> hangs) */
ULONG sup_invert_body(UBYTE *buf, ULONG n)
{
	ULONG c = n;
	do {
		UBYTE v = 0xff;
		v -= *buf;
		*buf++ = v;
		c--;
	} while (c != 0);
	return c;
}

/* -66 Gray: per column, mean of (row0,row1,row2) bytes.
   d0 = row-triple count, d1 = column count (row width). */
ULONG sup_gray_body(UBYTE *buf, ULONG rows, ULONG cols)
{
	UBYTE *p = buf;
	ULONG d0 = rows;
	short d7;
	for (;;) {
		d7 = (short)cols - 1;
	col:
		{
			ULONG v = p[0] / 3 + p[cols] / 3 + p[2 * cols] / 3;
			p[0] = p[cols] = p[2 * cols] = (UBYTE)v;
		}
		p++;
		if (d0 == 0)
			return 0;
		if (--d7 != -1)
			goto col;
		d7 = (short)cols - 1;
		p += 2 * cols;
		d0--;
	}
}

/* -72 Scanline: clear the second triple of each 6*rowlen block */
ULONG sup_scanline_body(UBYTE *buf, ULONG rowlen, ULONG total)
{
	ULONG *p = (ULONG *)(buf + 3 * rowlen);
	LONG t = (LONG)total;
	for (;;) {
		LONG c = (LONG)rowlen;
		do {
			*p++ = 0;
			c -= 2;
		} while (c > 0);
		c = (LONG)rowlen;
		do {
			*p++ = 0;
			c -= 4;
		} while (c > 0);
		p = (ULONG *)((UBYTE *)p + 3 * rowlen);
		t -= 6 * (LONG)rowlen;
		if (t <= 0)
			return rowlen;
	}
}

/* -78 Dither: clear every other byte over d0 bytes */
ULONG sup_dither_body(UBYTE *buf, ULONG n)
{
	LONG c = (LONG)n;
	do {
		*buf++ = 0;
		buf++;
		c -= 2;
	} while (c > 0);
	return (ULONG)c;
}

/* -84 Swap3: walk triples from both ends; each end receives the
   other's triple in reversed byte order (mirror + R<->B). */
ULONG sup_swap3_body(UBYTE *buf, ULONG n)
{
	UBYTE *b = buf;
	UBYTE *e = buf + n - 3;
	LONG c = (LONG)(n >> 1);
	UBYTE s[6];
	do {
		s[0] = b[2]; s[1] = b[1]; s[2] = b[0];
		s[3] = e[2]; s[4] = e[1]; s[5] = e[0];
		e[0] = s[0]; e[1] = s[1]; e[2] = s[2];
		b[0] = s[3]; b[1] = s[4]; b[2] = s[5];
		b += 3;
		e -= 3;
		c -= 3;
	} while (c > 0);
	return (ULONG)c;
}

/* -90 Mirror: reverse each byte row; 3*rows rows of width bytes.
   Front/back pointers are carried between rows (+width+width/2 and
   +width/2), so odd widths drift one byte per row. */
ULONG sup_mirror_body(UBYTE *buf, ULONG width, ULONG rows)
{
	short trips = (short)(3 * rows) - 1;
	ULONG half = width >> 1;
	UBYTE *f = buf;
	UBYTE *bk = buf + width - 1;
	do {
		short c = (short)half - 1;
		do {
			UBYTE t = *f;
			*f++ = *bk;
			*bk = t;
			bk--;
			c--;
		} while (c != -1);
		bk += width + half;
		f += half;
		trips--;
	} while (trips != -1);
	return half - 1;		/* d0 residue */
}

/* -96 SwapRB: per row triple, swap row0 <-> row2 longs.
   d2 = remaining bytes; decremented by 3*rowlen per triple. */
ULONG sup_swaprb_body(UBYTE *buf, ULONG rowlen, LONG total)
{
	ULONG *f = (ULONG *)buf;
	ULONG *bk = (ULONG *)(buf + 2 * rowlen);
	LONG t = total;
	for (;;) {
		LONG c = (LONG)rowlen;
		do {
			ULONG a = *f, b = *bk;
			*bk++ = a;
			*f++ = b;
			c -= 4;
		} while (c > 0);
		f = (ULONG *)((UBYTE *)f + 2 * rowlen);
		bk = (ULONG *)((UBYTE *)bk + 2 * rowlen);
		t -= 3 * (LONG)rowlen;
		if (t <= 0)
			return rowlen;
	}
}

/* -102 Mosaic: in-place 10x10 block average.  Image is row-triples
   (R,G,B byte rows) of width w; d1 = row-triple count; a4 = the
   caller-supplied mathffp.library base (the library itself never
   opens mathffp). */
ULONG sup_mosaic_body(UBYTE *src, ULONG w, ULONG h, APTR mffp)
{
	ULONG *s = sup_scratch;
	UBYTE *p = src;
	short d2, d5;				/* dbf counters (16-bit) */
	ULONG d6;

	s[0] = w;
	s[3] = h;
	s[1] = w;
	s[2] = w;
	s[11] = w;
	s[11] -= 10;				/* d6 = w - 10 */

	{
		ULONG q = s[0] / 10;
		s[1] = q;
		s[1] -= 1;				/* w/10 - 1 */
		s[2] -= q * 10;				/* w % 10 */
		s[4] = s[3];
		s[5] = s[3];
		q = s[4] / 10;
		s[4] = q;
		s[4] -= 1;				/* h/10 - 1 */
		s[5] -= q * 10;				/* h % 10 */
	}

	d2 = (short)s[1];
	d5 = (short)s[4];
	d6 = s[11];

rowblk:
colblk:
	for (;;) {
		short d4;
		int i;

		/* sum three channel rows over the 10x10 block */
		s[7] = s[8] = s[9] = 0;
		d4 = 9;
		do {
			for (i = 0; i < 10; i++)
				s[7] += *p++;
			p += d6;
			for (i = 0; i < 10; i++)
				s[8] += *p++;
			p += d6;
			for (i = 0; i < 10; i++)
				s[9] += *p++;
			p += d6;
		} while (d4-- != 0);

		/* mean = SPFix(SPDiv(SPFlt(sum), SPFlt(100))) per channel */
		s[7] = mf_flt(mffp, s[7]);		/* float sum0 stored */
		s[10] = mf_flt(mffp, 100);		/* float(100) */
		s[7] = mf_fix(mffp, mf_div(mffp, s[7], s[10]));
		s[8] = mf_fix(mffp, mf_div(mffp, mf_flt(mffp, s[8]), s[10]));
		s[9] = mf_fix(mffp, mf_div(mffp, mf_flt(mffp, s[9]), s[10]));

		/* write the three channel means back over the block */
		{
			ULONG back = s[0] * 30;
			UBYTE *q = p - back;
			d4 = 9;
			do {
				for (i = 0; i < 10; i++)
					*q++ = (UBYTE)s[7];
				q += d6;
				for (i = 0; i < 10; i++)
					*q++ = (UBYTE)s[8];
				q += d6;
				for (i = 0; i < 10; i++)
					*q++ = (UBYTE)s[9];
				q += d6;
			} while (d4-- != 0);
			q -= back;
			q += 10;
			p = q;
		}

		if (--d2 != -1)
			goto colblk;
		p += s[2];				/* remainder columns */
		p += s[0] * 30 - s[0];			/* next row block */
		d2 = (LONG)s[1];
		if (--d5 == -1)
			return s[0] * 30;	/* d0 residue */
		goto rowblk;
	}
}

/* -108 Transpose: scatter column-triples of a row-interleaved
   (3*h byte-rows) region into per-column channel planes at dst.
   dst[c][chan][r] = src[r][chan][c]; writes 3*w*h bytes total.
   Args: a0=src, a1=dst, d0=w (columns), d1=h (rows). */
ULONG sup_transpose_body(UBYTE *src, UBYTE *dst, ULONG w, ULONG h)
{
	ULONG *s = sup_scratch;
	UBYTE *s0 = src, *s1 = src + w, *s2 = src + 2 * w;
	UBYTE *d0 = dst, *d1 = dst + h, *d2 = dst + 2 * h;
	ULONG step = 3 * w;
	ULONG back = step * h;
	ULONG dskip = 2 * h;
	short cols = (short)w - 1;
	short cnt;

	s[0] = (ULONG)dst;
	s[1] = (ULONG)src;
	s[2] = w;
	s[3] = h;

	cnt = (short)h - 1;
	do {
		do {
			*d0++ = *s0;
			*d1++ = *s1;
			*d2++ = *s2;
			s0 += step;
			s1 += step;
			s2 += step;
			cnt--;
		} while (cnt != -1);
		d0 += dskip;
		d1 += dskip;
		d2 += dskip;
		s0 -= back;
		s1 -= back;
		s2 -= back;
		s0++;
		s1++;
		s2++;
		cnt = (short)h - 1;
		cols--;
	} while (cols != -1);
	return h;			/* d0 residue */
}
