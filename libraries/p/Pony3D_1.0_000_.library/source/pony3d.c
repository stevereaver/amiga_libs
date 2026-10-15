/* Pony3D.library 1.0 (13-Feb-2000) — reconstruction
 *
 * Tomasz "Pony van Deathface" P.czek's 3D vertex-math helper
 * library (ASM-One 1.25).  Fixed-point rotate / translate /
 * perspective-project / bitplane-plot on int16 vertex lists.
 *
 * Shipped quirks reproduced faithfully — see okf/findings:
 *  - List-format is [count][elements]; the count is a dbf
 *    counter so count+1 elements are processed (count is a
 *    "last index" convention).
 *  - Rotate angles are in half-table-step units (even values
 *    0..510 index a 256-entry sine / 256-entry cosine pair);
 *    +2 is added to each angle at entry and wraps mod 512.
 *  - Project divides cx AND cy by 2 INSIDE the per-vertex
 *    loop: the center collapses toward 0 as the list runs
 *    (and the divsw remainder bits accumulate in the high
 *    word of the register for odd inputs).
 *  - Plot bit = (~x)&7 (MSB-first Amiga bit order).
 */

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef short          WORD;
typedef long           LONG;
typedef unsigned long  ULONG;
typedef void          *APTR;

#define REGPARM_A0 __asm("a0")
#define REGPARM_A1 __asm("a1")
#define REGPARM_D0 __asm("d0")
#define REGPARM_D1 __asm("d1")
#define REGPARM_D2 __asm("d2")
#define REGPARM_D4 __asm("d4")
#define REGPARM_D5 __asm("d5")
#define REGPARM_D6 __asm("d6")

/* dbf loop: body runs count+1 times (counter underflow stops). */
#define DBFLOOP(cnt, ...) do { WORD _c = (WORD)(cnt); \
	do { __VA_ARGS__; } while ((WORD)--_c != (WORD)-1); } while (0)

/* mulsw: signed 16x16 -> 32 product */
static inline LONG muls16(WORD a, WORD b)
{
	LONG r = a;
	__asm__("mulsw %1,%0" : "+d"(r) : "g"(b));
	return r;
}

/* divsw: signed 32/16 -> quotient.w + remainder.w (full dst) */
static inline LONG divs16(LONG v, WORD d)
{
	LONG r = v;
	__asm__("divsw %1,%0" : "+d"(r) : "g"(d));
	return r;
}

/* 512-word trig table verbatim from the original DATA hunk:
 *   sin(a) = tab[a>>1]      a in 0..510 (byte-offset indexing)
 *   cos(a) = tab[256+a>>1]
 * values ~ -sin(i*2pi/256)*256 / cos(i*2pi/256)*256 (8.8 fix). */
static const WORD sintab[512] = {
	   1,   -5,  -12,  -18,  -24,  -30,  -37,  -43,
	 -49,  -55,  -61,  -67,  -73,  -79,  -85,  -91,
	 -97, -103, -108, -114, -120, -125, -131, -136,
	-141, -146, -151, -156, -161, -166, -171, -176,
	-180, -184, -189, -193, -197, -201, -205, -208,
	-212, -215, -219, -222, -225, -228, -230, -233,
	-236, -238, -240, -242, -244, -246, -247, -249,
	-250, -251, -252, -253, -254, -254, -255, -255,
	-255, -255, -255, -254, -254, -253, -252, -251,
	-250, -249, -247, -246, -244, -242, -240, -238,
	-236, -233, -230, -228, -225, -222, -219, -215,
	-212, -208, -205, -201, -197, -193, -189, -184,
	-180, -176, -171, -166, -161, -156, -151, -146,
	-141, -136, -131, -125, -120, -114, -108, -103,
	 -97,  -91,  -85,  -79,  -73,  -67,  -61,  -55,
	 -49,  -43,  -37,  -30,  -24,  -18,  -12,   -5,
	   1,    6,   13,   19,   25,   31,   38,   44,
	  50,   56,   62,   68,   74,   80,   86,   92,
	  98,  104,  109,  115,  121,  126,  132,  137,
	 142,  147,  152,  158,  162,  167,  172,  177,
	 181,  185,  190,  194,  198,  202,  206,  209,
	 213,  216,  220,  223,  226,  229,  231,  234,
	 237,  239,  241,  243,  245,  247,  248,  250,
	 251,  252,  253,  254,  255,  255,  256,  256,
	 256,  256,  256,  255,  255,  254,  253,  252,
	 251,  250,  248,  247,  245,  243,  241,  239,
	 237,  234,  231,  229,  226,  223,  220,  216,
	 213,  209,  206,  202,  198,  194,  190,  185,
	 181,  177,  172,  167,  162,  157,  152,  147,
	 142,  137,  132,  126,  121,  115,  109,  104,
	  98,   92,   86,   80,   74,   68,   62,   56,
	  50,   44,   38,   31,   25,   19,   13,    6,
	 256,  256,  256,  255,  255,  254,  253,  252,
	 251,  250,  248,  247,  245,  243,  241,  239,
	 237,  234,  231,  229,  226,  223,  220,  216,
	 213,  209,  206,  202,  198,  194,  190,  185,
	 181,  177,  172,  167,  162,  157,  152,  147,
	 142,  137,  132,  126,  121,  115,  109,  104,
	  98,   92,   86,   80,   74,   68,   62,   56,
	  50,   44,   38,   31,   25,   19,   13,    6,
	   1,   -5,  -12,  -18,  -24,  -30,  -37,  -43,
	 -49,  -55,  -61,  -67,  -73,  -79,  -85,  -91,
	 -97, -103, -108, -114, -120, -125, -131, -136,
	-141, -146, -151, -156, -161, -166, -171, -176,
	-180, -184, -189, -193, -197, -201, -205, -208,
	-212, -215, -219, -222, -225, -228, -230, -233,
	-236, -238, -240, -242, -244, -246, -247, -249,
	-250, -251, -252, -253, -254, -254, -255, -255,
	-255, -255, -255, -254, -254, -253, -252, -251,
	-250, -249, -247, -246, -244, -242, -240, -238,
	-236, -233, -230, -228, -225, -222, -219, -215,
	-212, -208, -205, -201, -197, -193, -189, -184,
	-180, -176, -171, -166, -161, -156, -151, -146,
	-141, -136, -131, -125, -120, -114, -108, -103,
	 -97,  -91,  -85,  -79,  -73,  -67,  -61,  -55,
	 -49,  -43,  -37,  -30,  -24,  -18,  -12,   -5,
	   1,    6,   13,   19,   25,   31,   38,   44,
	  50,   56,   62,   68,   74,   80,   86,   92,
	  98,  104,  109,  115,  121,  126,  132,  137,
	 142,  147,  152,  158,  162,  167,  172,  177,
	 181,  185,  190,  194,  198,  202,  206,  209,
	 213,  216,  220,  223,  226,  229,  231,  234,
	 237,  239,  241,  243,  245,  247,  248,  250,
	 251,  252,  253,  254,  255,  255,  256,  256,
};

/* byte-offset indexed trig access (reproduces a4@(0,a0:w)) */
static inline WORD SIN(WORD a)
	{ return *(const WORD *)((const UBYTE *)sintab + (WORD)a); }
static inline WORD COS(WORD a)
	{ return *(const WORD *)((const UBYTE *)sintab + 512 + (WORD)a); }

/*--------------------------- -30 ---------------------------*/
/* RotatePoints(src:a0, dst:a1, ax:d4, ay:d5, az:d6)
 * list: [count][x,y,z]*  — rotates each vertex Euler-style
 * around X (ax), then Y (ay), then Z (az). */
void _Rotate(WORD *src REGPARM_A0, WORD *dst REGPARM_A1,
	     WORD ax REGPARM_D4, WORD ay REGPARM_D5, WORD az REGPARM_D6)
{
	WORD n;

	ax = (WORD)(ax + 2) & 511;
	ay = (WORD)(ay + 2) & 511;
	az = (WORD)(az + 2) & 511;

	n = *src++;
	*dst++ = n;
	DBFLOOP(n, {
		WORD x = *src++, y = *src++, z = *src++;
		WORD t;
		/* (d1,d2) pair rotate by ax */
		t = (WORD)((muls16(y, COS(ax)) - muls16(z, SIN(ax))) >> 8);
		y = (WORD)((muls16(y, SIN(ax)) + muls16(z, COS(ax))) >> 8);
		z = t;
		/* (d0,d2) pair rotate by ay */
		t = (WORD)((muls16(x, COS(ay)) - muls16(z, SIN(ay))) >> 8);
		z = (WORD)((muls16(x, SIN(ay)) + muls16(z, COS(ay))) >> 8);
		x = t;
		/* (d0,d1) pair rotate by az */
		t = (WORD)((muls16(x, COS(az)) - muls16(y, SIN(az))) >> 8);
		y = (WORD)((muls16(x, SIN(az)) + muls16(y, COS(az))) >> 8);
		x = t;
		*dst++ = x; *dst++ = y; *dst++ = z;
	});
}

/*--------------------------- -36 ---------------------------*/
/* TranslatePoints(src:a0, dst:a1, dx:d0, dy:d1, dz:d2) */
void _Translate(WORD *src REGPARM_A0, WORD *dst REGPARM_A1,
		WORD dx REGPARM_D0, WORD dy REGPARM_D1, WORD dz REGPARM_D2)
{
	WORD n = *src++;
	*dst++ = n;
	DBFLOOP(n, {
		WORD x = *src++, y = *src++, z = *src++;
		*dst++ = (WORD)(x + dx);
		*dst++ = (WORD)(y + dy);
		*dst++ = (WORD)(z + dz);
	});
}

/*--------------------------- -42 ---------------------------*/
/* ProjectPoints(src:a0, dst:a1, focal:d0, cx:d1, cy:d2)
 * writes [count][sx,sy]* ; sx = cx' + x*f/z ; z==0 -> 1.
 * cx/cy are FULL divsw registers (quot.w + rem.w) halved
 * every iteration — the center decays as the list runs. */
void _Project(WORD *src REGPARM_A0, WORD *dst REGPARM_A1,
	      WORD f REGPARM_D0, LONG cx REGPARM_D1, LONG cy REGPARM_D2)
{
	WORD n = *src++;
	*dst++ = n;
	DBFLOOP(n, {
		WORD x = *src++, y = *src++, z = *src++;
		LONG q;
		cx = divs16(cx, 2);	/* inside the loop (quirk) */
		cy = divs16(cy, 2);
		if (z == 0) z = 1;	/* addiw #1 on zero only   */
		q = divs16(muls16(x, f), z);
		*dst++ = (WORD)(q + (WORD)cx);
		q = divs16(muls16(y, f), z);
		*dst++ = (WORD)(q + (WORD)cy);
	});
}

/*--------------------------- -48 ---------------------------*/
/* Plot(list:a0, plane:a1) — [count][x,y]* sets bit (~x)&7 at
 * byte y*40 + (x>>3) in a 40-byte-pitch bitplane. */
void _Plot(WORD *list REGPARM_A0, UBYTE *plane REGPARM_A1)
{
	WORD n = *list++;
	DBFLOOP(n, {
		WORD x = *list++, y = *list++;
		UWORD off = (UWORD)((UWORD)y * 40) + (UWORD)((UWORD)x >> 3);
		plane[off] |= (UBYTE)(1 << ((~x) & 7));
	});
}
