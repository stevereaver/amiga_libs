/*
**	xpkhfmn.library V1.28 -- reconstructed implementation
**	"xpkHFMN.library Version 1.28 (Thu Sep 22 18:47:29 1994)
**	 (c) Martin Hauner 68020+ Version"
**
**	XPK sublibrary: "dyn. Huffman.020+ Version 1.28"
**
**	Ancestor of xpkHFMN 1.4: same dynamic-Huffman codec, same
**	workmem layout and same stream format
**	(u16 treeBytes | preorder tree ('1' internal, '0'+8 LSB sym)
**	 | u16 inLen | MSB-first codes), but:
**
**	  - packer emits data codes with a real 68020 BFINS
**	  - no bounds checks during emit; single OutLen<=OutBufLen
**	    check at the very end (returns -17 afterwards)
**	  - unpacker does NOT interpret the tree: LAB_0039 compiles
**	    the packed tree description into 68000 machine code in the
**	    work buffer and calls it with JSR (a4).  Each internal
**	    node is "add.l d0,d0 ; bcc.w <skip>", each leaf is
**	    "moveq #sym,d1 ; move.b d1,(a2)+ ; moveq #depth,d1 ;
**	    dbf d7,entry ; rts".  A 28-byte template provides the
**	    entry counter, initial move.l load and the 16-bit refill
**	    helper; leaf dbf loops back through the helper which
**	    charges the leaf depth against a 16-bit refill budget.
**	  - workmem is AllocMem'd/freed per call (no Sub[] slots)
**	  - functab is the LONG form, not word offsets
**
**	Work buffer layouts (AllocMem MEMF_CLEAR):
**
**	  pack 0x1a0a bytes:
**	    +0x0002 u16 freq[512]   ([0..255] syms, [0x100+n] internal)
**	    +0x0402 u16 heap[257]   (1-based)
**	    +0x0606 s16 parent[512] (sign = direction, + = '1' side)
**	    +0x0a06 u16 child[id*2+dir] (+0='0', +2='1')
**	    +0x120a u32 code[256]
**	    +0x160a u32 len[256]    (low byte used)
**
**	  unpack 0x19fa bytes:
**	    +0x0000 generated decoder code (<= ~5KB)
**	    +0x13fa generator fixup stack {u32 nodeptr, u16 serial}
*/

#ifdef HOST_TEST
#define __asm(x)
#include <stdint.h>
typedef uint8_t		UBYTE;
typedef uint16_t	UWORD;
typedef uint32_t	ULONG;
typedef int32_t		LONG;
typedef int16_t		SHORT;
typedef int8_t		BYTE;
typedef void	       *APTR;
typedef char	       *STRPTR;
#define LIBF_DELEXP	0x08
#define MEMF_CLEAR	0x10000UL
struct Node {
	struct Node *ln_Succ;
	struct Node *ln_Pred;
	UBYTE  ln_Type;
	BYTE   ln_Pri;
	char  *ln_Name;
};
struct Library {
	struct Node ln;
	UWORD  lib_Flags;
	UWORD  lib_NegSize;
	UWORD  lib_PosSize;
	UWORD  lib_Version;
	UWORD  lib_Revision;
	ULONG  lib_IdString;
	ULONG  lib_Sum;
	UWORD  lib_OpenCnt;
};
void *host_AllocMem(ULONG);
void host_FreeMem(APTR, ULONG);
void host_cacheclear(void);
#else
#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/memory.h>
#include <exec/execbase.h>
#endif

struct XpkSubParams {
	APTR	xsp_InBuf;		/* +0			    */
	ULONG	xsp_InLen;		/* +4			    */
	APTR	xsp_OutBuf;		/* +8			    */
	ULONG	xsp_OutBufLen;		/* +12			    */
	ULONG	xsp_OutLen;		/* +16			    */
	ULONG	xsp_Flags;		/* +20			    */
	ULONG	xsp_Number;		/* +24			    */
	ULONG	xsp_Mode;		/* +28			    */
	STRPTR	xsp_Password;		/* +32			    */
	UWORD	xsp_LibVersion;		/* +36			    */
	UWORD	xsp_Pad;		/* +38			    */
	ULONG	xsp_Arg[3];		/* +40			    */
	APTR	xsp_Sub[4];		/* +52			    */
};

struct HfmnBase {
	struct Library	 lib;
	APTR		 seglist;	/* +34			    */
	APTR		 xpkinfo;	/* +38 descriptor pointer    */
};

/* -------- exec LVO calls ------------------------------------------ */
#ifdef HOST_TEST
#define ALLOCMEM(sz,f)		host_AllocMem(sz)
#define FREEMEM(p,s)		host_FreeMem(p,s)
#define CACHECLEAR()		host_cacheclear()
#define ATTNFLAGS()		host_attnflags()
#define EXECVER()		host_execver()
UWORD host_attnflags(void);
UWORD host_execver(void);
#else
static void ex_freemem(APTR mem, ULONG sz)
{ register APTR __m __asm("a1") = mem; register ULONG __s __asm("d0") = sz;
  register APTR __e __asm("a6") = *(APTR *)4;
  __asm volatile("jsr %/a6@(-210)\n"
      ::"r"(__m),"r"(__s),"r"(__e):"d1","a0","cc","memory"); }
static APTR ex_allocmem(ULONG sz, ULONG flags)
{ register ULONG __s __asm("d0") = sz; register ULONG __f __asm("d1") = flags;
  register APTR __e __asm("a6") = *(APTR *)4;
  __asm volatile("jsr %/a6@(-198)\n"
      :"+r"(__s):"r"(__f),"r"(__e):"a0","a1","cc","memory");
  return (APTR)__s; }
static void ex_cacheclear(void)
{ register APTR __e __asm("a6") = *(APTR *)4;
  __asm volatile("jsr %/a6@(-636)\n"
      ::"r"(__e):"d0","d1","a0","a1","cc","memory"); }
#define ALLOCMEM(sz,f)		ex_allocmem(sz,f)
#define FREEMEM(p,s)		ex_freemem(p,s)
#define CACHECLEAR()		ex_cacheclear()
#define ATTNFLAGS()		(((struct ExecBase *)4)->AttnFlags)
#define EXECVER()		(((struct ExecBase *)4)->LibNode.lib_Version)
#endif

/* -------- endian-safe workmem access ------------------------------ */
#ifdef HOST_TEST
static UWORD rd16(const void *p)
	{ const UBYTE *b = p; return (UWORD)((b[0]<<8)|b[1]); }
static ULONG rd32(const void *p)
	{ const UBYTE *b = p;
	  return ((ULONG)b[0]<<24)|((ULONG)b[1]<<16)|((ULONG)b[2]<<8)|b[3]; }
static void wr16(void *p, UWORD v)
	{ UBYTE *b = p; b[0]=v>>8; b[1]=v; }
static void wr32(void *p, ULONG v)
	{ UBYTE *b = p; b[0]=v>>24; b[1]=v>>16; b[2]=v>>8; b[3]=v; }
#define NRD16(p)	rd16(p)
#define NWR16(p,v)	wr16(p,v)
#define NRD32(p)	rd32(p)
#define NWR32(p,v)	wr32(p,v)
#else
#define NRD16(p)	(*(const UWORD *)(p))
#define NWR16(p,v)	(*(UWORD *)(p) = (v))
#define NRD32(p)	(*(const ULONG *)(p))
#define NWR32(p,v)	(*(ULONG *)(p) = (v))
#endif

/* -------------------------------------------------------------- */
/* pack workmem							    */
/* -------------------------------------------------------------- */

#define WK_FREQ		0x0002		/* u16 freq[512]	    */
#define WK_HEAP		0x0402		/* u16 heap[257] 1-based   */
#define WK_PARENT	0x0606		/* s16 parent[512]	    */
#define WK_CHILD	0x0a06		/* u16 child[id*2+dir]     */
#define WK_CODES	0x120a		/* u32 code[256]	    */
#define WK_LENS		0x160a		/* u32 len[256]	    */
#define PWK_ALLOC	0x1a0a

#define UWK_ALLOC	0x19fa
#define UWK_STACK	0x13fa		/* fixup stack offset	    */

#define FREQ(wk,id)	NRD16((UBYTE *)(wk) + WK_FREQ + 2*(id))
#define SFREQ(wk,id,v)	NWR16((UBYTE *)(wk) + WK_FREQ + 2*(id), (v))
#define HEAP(wk,i)	NRD16((UBYTE *)(wk) + WK_HEAP + 2*(i))
#define SHEAP(wk,i,v)	NWR16((UBYTE *)(wk) + WK_HEAP + 2*(i), (v))
#define PARENT(wk,id)	((SHORT)NRD16((UBYTE *)(wk) + WK_PARENT + 2*(id)))
#define SPARENTP(wk,id,v) NWR16((UBYTE *)(wk) + WK_PARENT + 2*(id),(UWORD)(v))
#define CHILD0(wk,id)	NRD16((UBYTE *)(wk) + WK_CHILD + 4*(id))
#define CHILD1(wk,id)	NRD16((UBYTE *)(wk) + WK_CHILD + 4*(id) + 2)
#define SCHILD0(wk,id,v) NWR16((UBYTE *)(wk) + WK_CHILD + 4*(id), (v))
#define SCHILD1(wk,id,v) NWR16((UBYTE *)(wk) + WK_CHILD + 4*(id) + 2, (v))
#define CODES(wk,s)	NRD32((UBYTE *)(wk) + WK_CODES + 4*(s))
#define SCODES(wk,s,v) NWR32((UBYTE *)(wk) + WK_CODES + 4*(s), (v))
#define LENS(wk,s)	NRD32((UBYTE *)(wk) + WK_LENS + 4*(s))
#define SLENS(wk,s,v)	NWR32((UBYTE *)(wk) + WK_LENS + 4*(s), (v))

/* LAB_0029 -- heap sift-down: sift(i, size)			    */
static void sift(UBYTE *wk, UWORD i, UWORD size)
{
	UWORD half = size >> 1;
	while (i <= half) {
		UWORD c = i + i;
		UWORD f = FREQ(wk, HEAP(wk, c));
		UWORD t;
		if (c < size) {
			t = FREQ(wk, HEAP(wk, c + 1));
			if (t <= f) { c++; f = t; }
		}
		t = HEAP(wk, i);
		if (FREQ(wk, t) <= f)
			break;
		SHEAP(wk, i, HEAP(wk, c));
		SHEAP(wk, c, t);
		i = c;
	}
}

/* -36 XpksPackChunk: LAB_0006					    */
LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"))
{
	UBYTE *wk;
	const UBYTE *in, *ip;
	UBYTE *out, *a1;
	ULONG inlen, nused, d0, d7;
	int i;

	if (!(ATTNFLAGS() & 2))		/* AFF_68020 required	    */
		return -21;

	wk = ALLOCMEM(PWK_ALLOC, MEMF_CLEAR);
	if (!wk)
		return -7;

	in = xsp->xsp_InBuf;
	out = xsp->xsp_OutBuf;
	inlen = xsp->xsp_InLen;

	/* LAB_0030 histogram: 16-bit dbf, inlen==0 wraps to 64K    */
	d0 = (inlen - 1) & 0xffff;
	ip = in;
	for (;;) {
		UWORD sym = *ip++;
		SFREQ(wk, sym, (UWORD)(FREQ(wk, sym) + 1));
		d0 = (d0 - 1) & 0xffff;
		if (d0 == 0xffff)
			break;
	}

	/* LAB_002D: used symbols descending into heap[1..]	    */
	nused = 0;
	for (i = 0xff;; i--) {
		if (FREQ(wk, (UWORD)i))
			SHEAP(wk, ++nused, (UWORD)i);
		if (!i)
			break;
	}

	d7 = nused >> 1;
	if (!d7) {
		/* LAB_0028: <=1 symbol: phantom sym-0 '0' sibling */
		UWORD s = HEAP(wk, 1);
		SFREQ(wk, 0x101, FREQ(wk, s));
		SPARENTP(wk, s, 0x0101);
		SPARENTP(wk, 0, 0xfeff);
	} else {
		/* heapify sift(nused/2..1), then merges with d7=nused-1 */
		for (i = (int)(nused >> 1); i >= 1; i--)
			sift(wk, (UWORD)i, (UWORD)nused);
		d7 = nused - 1;
		for (;;) {		/* LAB_0026 merges	    */
			UWORD d5, d4, nid;
			d5 = HEAP(wk, 1);
			SHEAP(wk, 1, HEAP(wk, d7 + 1));
			SHEAP(wk, d7 + 1, 0);
			sift(wk, 1, (UWORD)d7);
			d4 = HEAP(wk, 1);
			nid = (UWORD)(0x100 + d7);
			SFREQ(wk, nid, (UWORD)(FREQ(wk, d4)
					     + FREQ(wk, d5)));
			SHEAP(wk, 1, nid);
			SPARENTP(wk, d4, nid);		/* + = '1' */
			SPARENTP(wk, d5, (SHORT)-nid);	/* - = '0' */
			sift(wk, 1, (UWORD)d7);
			if (d7 == 1)
				break;
			d7--;
		}
	}

	/* LAB_001F: codes leaf-up; fills CHILD table en route	    */
	for (i = 0xff;; i--) {
		ULONG code = 0;
		ULONG len = 0;
		UWORD id = (UWORD)i;
		SHORT p;
		while ((p = PARENT(wk, id)) != 0) {
			if (p > 0) {
				code |= 1UL << len;
				SCHILD1(wk, (UWORD)p, id);
			} else {
				SCHILD0(wk, (UWORD)-p, id);
			}
			id = (UWORD)(p > 0 ? p : -p);
			len++;
		}
		SCODES(wk, i, code);
		SLENS(wk, i, len);
		if (!i)
			break;
	}

	/* LAB_0017: preorder tree stream into out+2, len at out    */
	{
		ULONG acc = 1;
		ULONG nbytes = 0;
		UBYTE *a3 = out + 2;
		UWORD d1, cur, sym;
		SHORT p;

#define EMIT(bit) do {						\
		ULONG __c = acc >> 31;				\
		acc = (acc << 1) | (bit);			\
		if (__c) {					\
			NWR32(a3, acc); a3 += 4; nbytes += 4;	\
			acc = 1;				\
		}						\
	} while (0)

		d1 = 0x101;
		for (;;) {
			cur = CHILD1(wk, d1);
			if (cur > 0x100) {
				EMIT(1);
				d1 = cur;
				continue;
			}
			for (;;) {
				int k;
				sym = cur;
				EMIT(0);
				for (k = 0; k < 8; k++)
					EMIT((sym >> k) & 1);
				for (;;) {
					p = PARENT(wk, sym);
					if (!p)
						goto tree_done;
					if (p < 0) {
						sym = (UWORD)-p;
						continue;
					}
					cur = CHILD0(wk, (UWORD)p);
					break;
				}
				if (cur > 0x100) {
					EMIT(1);
					d1 = cur;
					break;
				}
			}
		}
tree_done:
		/* LAB_001E: ADDX pad; X=1 on entry then X=carry   */
		{
			ULONG xf = 1;
			for (;;) {
				ULONG c = acc >> 31;
				acc = (acc << 1) | xf;
				xf = c;
				if (c)
					break;
			}
		}
		NWR32(a3, acc);
		a3 += 4; nbytes += 4;
		NWR16(out, (UWORD)nbytes);
#undef EMIT

		xsp->xsp_OutLen = nbytes + 2;

		/* LAB_0015: inlen word + BFINS data codes	    */
		a1 = out + 2 + nbytes;
		NWR16(a1, (UWORD)inlen);
		a1 += 2;
		{
			ULONG d5 = 0;
			ULONG d7c = (inlen - 1) & 0xffff;
			ip = in;
			for (;;) {
				ULONG sym = *ip++;
				ULONG c = CODES(wk, sym);
				ULONG l = (UBYTE)LENS(wk, sym);
				while (l--) {
					ULONG bp = d5 >> 3;
					if (c & (1UL << l))
						a1[bp] |= 1 << (7 - (d5 & 7));
					else
						a1[bp] &= ~(1 << (7 - (d5 & 7)));
					d5++;
				}
				d7c = (d7c - 1) & 0xffff;
				if (d7c == 0xffff)
					break;
			}
			xsp->xsp_OutLen += 5 + (d5 >> 3);
		}
	}

	/* end-of-function bound check: OutLen <= xsp_OutBufLen	    */
	d7 = (xsp->xsp_OutLen <= xsp->xsp_OutBufLen) ? 0 : (ULONG)-17;

	FREEMEM(wk, PWK_ALLOC);
	return (LONG)d7;
}

/* -------------------------------------------------------------- */
/* LAB_0039 -- decoder code generator				    */
/* -------------------------------------------------------------- */

/* 28-byte template copied to the head of the generated code:
**   subq.w #1,d7 ; move.l (a0)+,d0 ; moveq #16,d2 ; moveq #16,d4
**   bra.s +28    ; <- helper: sub.b d1,d2 ; bhi.s root
**                  neg.b d2 ; moveq #0,d3 ; move.w (a0)+,d3
**                  lsl.l d2,d3 ; add.l d3,d0 ; neg.b d2 ; add.b d4,d2
**   root:        (first emitted node goes here)                  */
static const UBYTE gen_template[28] = {
	0x53,0x47, 0x20,0x18, 0x74,0x10, 0x78,0x10,
	0x60,0x12, 0x94,0x01, 0x62,0x0e, 0x44,0x02,
	0x76,0x00, 0x36,0x18, 0xe5,0xab, 0xd0,0x83,
	0x44,0x02, 0xd4,0x04
};

/* generator's own tree-bit reader: 32-bit shift register whose
   bit0 sentinel re-arms on reload (addx semantics of LAB_003B)   */
static const UBYTE *g_src;
static ULONG g_d0;

static int gbit(void)
{
	ULONG c = g_d0 >> 31;
	g_d0 <<= 1;
	if (!g_d0) {				/* empty: reload+addx */
		ULONG f = NRD32(g_src); g_src += 4;
		c = f >> 31;
		g_d0 = (f << 1) | 1;
	}
	return (int)c;
}

/* emit one internal node: "add.l d0,d0 ; bcc.w +0"		    */
static void emit_node(UBYTE **pa1)
{
	UBYTE *a1 = *pa1;
	a1[0] = 0xd0; a1[1] = 0x80;
	a1[2] = 0x64; a1[3] = 0x00;
	a1[4] = 0x00; a1[5] = 0x00;
	*pa1 = a1 + 6;
}

/* emit one leaf: "moveq #sym,d1 ; move.b d1,(a2)+ ;
**                moveq #depth,d1 ; dbf d7,gen+10 ; rts"	    */
static void emit_leaf(UBYTE **pa1, UBYTE *gen, ULONG sym, ULONG depth)
{
	UBYTE *a1 = *pa1;
	ULONG disp;
	a1[0] = 0x72; a1[1] = (UBYTE)sym;
	a1[2] = 0x14; a1[3] = 0xc1;
	a1 += 4;
	a1[0] = 0x72; a1[1] = (UBYTE)depth;
	a1 += 2;
	a1[0] = 0x51; a1[1] = 0xcf;
	disp = (ULONG)((gen + 12) - (a1 + 4));
	a1[2] = (UBYTE)(disp >> 8); a1[3] = (UBYTE)disp;
	a1 += 4;
	a1[0] = 0x4e; a1[1] = 0x75;
	*pa1 = a1 + 2;
}

/* LAB_0039: compile the tree bitstream at src into code at gen.
   stk holds {u32 node offset, u16 serial} fixups (6B/entry).	    */
static void codegen(const UBYTE *src, UBYTE *gen, UBYTE *stk)
{
	UBYTE *a1 = gen;
	UBYTE *sp = stk;
	ULONG d7 = 0, d6 = 0, d1 = 0;
	int i;

	for (i = 0; i < 14; i++) {
		a1[0] = gen_template[i * 2];
		a1[1] = gen_template[i * 2 + 1];
		a1 += 2;
	}
	g_src = src;
	g_d0 = 0;

	/* root guard push {ptr=root node, serial=0} + root node    */
	NWR32(sp, (ULONG)(a1 - gen));
	NWR16(sp + 4, 0);
	sp += 6;
	d6 = 1;
	emit_node(&a1);

#define PUSH(off,v) do {					\
		NWR32(sp, (ULONG)(off));			\
		NWR16(sp + 4, (UWORD)(v));			\
		sp += 6;					\
	} while (0)
#define POP(pv,vv) do {						\
		sp -= 6;					\
		vv = NRD16(sp + 4);				\
		pv = gen + NRD32(sp);				\
	} while (0)
#define PATCH(pv) NWR16((pv) + 4, (UWORD)(a1 - (pv) - 4))

	for (;;) {
		if (gbit()) {
			/* '1': internal node marker	    */
			if (d1) {
				UBYTE *pv;
				d6--;
				if ((LONG)d6 < 0)
					return;		/* done	    */
				POP(pv, d7);
				PATCH(pv);
				d1 = 0;
			}
			d7++;
			PUSH(a1 - gen, d7);
			d6++;
			emit_node(&a1);
		} else {
			/* '0': leaf, 8 more bits		    */
			ULONG sym = 0;
			int k;
			for (k = 0; k < 8; k++)
				sym = (sym >> 1) | ((ULONG)gbit() << 7);
			if (!d1) {
				d7++;
				emit_leaf(&a1, gen, sym, d7);
				d7--;
				d1 = 1;
			} else {
				UBYTE *pv;
				d6--;
				if ((LONG)d6 < 0)
					return;		/* done	    */
				POP(pv, d7);
				d7++;
				PATCH(pv);
				emit_leaf(&a1, gen, sym, d7);
			}
		}
	}
#undef PUSH
#undef POP
#undef PATCH
}

/* -------------------------------------------------------------- */
/* HOST_TEST only: interpret the generated 68000 code		    */
/* -------------------------------------------------------------- */
#ifdef HOST_TEST
static void sim_decode(const UBYTE *gen, const UBYTE *src,
		       UBYTE *out, ULONG inlen)
{
	ULONG d0 = 0, d1, d2, d3, d4, d7;
	ULONG a0 = 0, a2 = 0, pc = 0;
	UBYTE *g = (UBYTE *)gen;
	int cc = 0;				/* carry flag	    */
	(void)inlen;
	d7 = inlen & 0xffff;
	for (;;) {
		ULONG op = (g[pc] << 8) | g[pc + 1];
		if (op == 0x5347) {		/* subq.w #1,d7	    */
			d7 = (d7 - 1) & 0xffff;
			pc += 2;
		} else if (op == 0x2018) {	/* move.l (a0)+,d0  */
			d0 = rd32(src + a0); a0 += 4; pc += 2;
		} else if (op == 0x7410) {	/* moveq #16,d2	    */
			d2 = 16; pc += 2;
		} else if (op == 0x7810) {	/* moveq #16,d4	    */
			d4 = 16; pc += 2;
		} else if ((op & 0xff00) == 0x6000) {	/* bra.s    */
			pc += 2 + (op & 0xff);
		} else if (op == 0x9401) {	/* sub.b d1,d2	    */
			cc = d1 > (d2 & 0xff);
			d2 = (d2 - d1) & 0xff;
			pc += 2;
		} else if ((op & 0xff00) == 0x6200) {	/* bhi.s    */
			pc += (cc == 0 && d2 != 0) ? 2 + (op & 0xff) : 2;
		} else if (op == 0x4402) {	/* neg.b d2	    */
			d2 = (-(int)(d2 & 0xff)) & 0xff;
			pc += 2;
		} else if (op == 0x7600) {	/* moveq #0,d3	    */
			d3 = 0; pc += 2;
		} else if (op == 0x3618) {	/* move.w (a0)+,d3  */
			d3 = rd16(src + a0); a0 += 2; pc += 2;
		} else if (op == 0xe5ab) {	/* lsl.l d2,d3	    */
			d3 = (d3 << (d2 & 63)) & 0xffffffffUL;
			pc += 2;
		} else if (op == 0xd083) {	/* add.l d3,d0	    */
			d0 = (d0 + d3) & 0xffffffffUL; pc += 2;
		} else if (op == 0xd404) {	/* add.b d4,d2	    */
			d2 = (d2 + d4) & 0xff; pc += 2;
		} else if (op == 0xd080) {	/* add.l d0,d0	    */
			cc = d0 >> 31;
			d0 = (d0 << 1) & 0xffffffffUL;
			pc += 2;
		} else if (op == 0x6400) {	/* bcc.w +disp16    */
			LONG disp = (SHORT)rd16(g + pc + 2);
			pc += cc ? 4 : 2 + disp;
		} else if ((op & 0xff00) == 0x7200) {	/* moveq #x,d1   */
			d1 = op & 0xff; pc += 2;
		} else if (op == 0x14c1) {	/* move.b d1,(a2)+  */
			out[a2++] = (UBYTE)d1; pc += 2;
		} else if (op == 0x51cf) {	/* dbf d7,+disp16   */
			LONG disp = (SHORT)rd16(g + pc + 2);
			d7 = (d7 - 1) & 0xffff;
			pc += (d7 != 0xffff) ? 2 + disp : 4;
		} else if (op == 0x4e75) {	/* rts		    */
			return;
		} else if (op == 0x4e71) {	/* nop		    */
			pc += 2;
		} else {
			return;			/* unknown	    */
		}
	}
}
#endif

/* -54 XpksUnpackChunk: LAB_0011				    */
LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"))
{
	UBYTE *wm, *a0;
	ULONG d7;

	wm = ALLOCMEM(UWK_ALLOC, MEMF_CLEAR);
	if (!wm)
		return -7;

	a0 = (UBYTE *)xsp->xsp_InBuf + 2;
	codegen(a0, wm, wm + UWK_STACK);

	if ((ATTNFLAGS() & 4) && EXECVER() >= 36)	/* 68030 + OS2.0    */
		CACHECLEAR();

	a0 = (UBYTE *)xsp->xsp_InBuf + 2;
	a0 += NRD16(xsp->xsp_InBuf) & 0x1ff;	/* treelen&0x1ff   */
	d7 = NRD16(a0);
	a0 += 2;

#ifdef HOST_TEST
	sim_decode(wm, a0, (UBYTE *)xsp->xsp_OutBuf, d7);
#else
	{
	register UBYTE *__gen __asm("a4") = wm;
	register const UBYTE *__in __asm("a0") = a0;
	register UBYTE *__out __asm("a2") = (UBYTE *)xsp->xsp_OutBuf;
	register ULONG __cnt __asm("d7") = d7;
	__asm volatile("jsr %/a4@\n"
	    :: "r"(__gen), "r"(__in), "r"(__out), "r"(__cnt)
	    : "d0","d1","d2","d3","d4","a1","cc","memory");
	}
#endif

	FREEMEM(wm, UWK_ALLOC);
	return 0;
}

/* -------------------------------------------------------------- */
/* library vectors						    */
/* -------------------------------------------------------------- */

/* -30 XpksPackerInfo: returns the descriptor stored at base+38   */
APTR XpksPackerInfo(struct XpkSubParams *xsp __asm("a0"),
		    struct HfmnBase *base __asm("a6"))
{
	return base->xpkinfo;
}

struct Library *LibOpen(struct HfmnBase *b __asm("a6"))
{
	++b->lib.lib_OpenCnt;
	b->lib.lib_Flags &= ~LIBF_DELEXP;
	return (struct Library *)b;
}

static ULONG expunge_body(struct HfmnBase *b)
{
	struct Node *n = (struct Node *)b;
	ULONG seg = (ULONG)b->seglist;
	ULONG sz = b->lib.lib_NegSize + b->lib.lib_PosSize;
	UBYTE *p = (UBYTE *)b - b->lib.lib_NegSize;
	/* original inlines the unlink: succ/pred splice, no Remove()  */
	n->ln_Succ->ln_Pred = n->ln_Pred;
	n->ln_Pred->ln_Succ = n->ln_Succ;
	FREEMEM(p, sz);
	return seg;
}

LONG LibClose(struct HfmnBase *b __asm("a6"))
{
	if (--b->lib.lib_OpenCnt == 0 && (b->lib.lib_Flags & LIBF_DELEXP))
		return (LONG)expunge_body(b);
	return 0;
}

/* -18 Expunge: the original does NOT check OpenCnt here -- an
   unconditional remove+free returning the seglist.		    */
ULONG LibExpunge(struct HfmnBase *b __asm("a6"))
{
	return expunge_body(b);
}

/* -24 Reserved: moveq #0,d0; rts (in lib.s as dedicated stub)    */
