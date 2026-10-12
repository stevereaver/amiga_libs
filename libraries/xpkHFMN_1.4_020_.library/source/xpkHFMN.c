/*
**	xpkHFMN.library V1.4 -- reconstructed implementation
**	"$VER: xpkHFMN V1.4 (1 Oct 2013) by Martin Hauner"
**
**	XPK sublibrary: "Fast Dynamic Huffman Statistic Compression"
**	(020+ -- BFINS/BFEXTU in the original).
**
**	Pack: byte histogram -> 1-based min-heap over used symbols
**	(heapify + pop2/merge) -> signed parent table + child records
**	-> preorder tree serialization ('1' per internal node,
**	'0' + 8 LSB-first symbol bits per leaf) into u16-counted
**	section, then inlen word + Huffman codes via 32-bit emit.
**
**	Unpack: trie of 4-byte nodes {slot0='1' child, slot1='0' child},
**	leaf nodes contain 0xffffffSS (negative long = leaf mark);
**	1024-entry 10-bit fast table {10-len,sym} positive or
**	(off-0x800) negative pointing into the trie for deep codes.
**
**	Workmem layouts (xsp_Sub[0] points past the size long):
**
**	  pack 0x1a0a body:
**	    +0x0002 u16 freq[512]   ([0..255] syms, [0x100+n] internal)
**	    +0x0402 u16 heap[257]   (1-based)
**	    +0x0606 s16 parent[512] (sign = direction, + = '1' side)
**	    +0x0a06 u16 child[512*2](id*4: +0='0' child, +2='1' child)
**	    +0x120a u32 code[256]
**	    +0x160a u32 len[256]
**
**	  unpack 0x1000 body:
**	    +0x0000 4B trie nodes   (offsets 0,4,...; max ~511 nodes)
**	    +0x0800 fast table + backptr scratch during build
*/

#ifdef HOST_TEST
#include <stdint.h>
typedef uint8_t		UBYTE;
typedef uint16_t	UWORD;
typedef uint32_t	ULONG;
typedef int32_t		LONG;
typedef int16_t		SHORT;
typedef void	       *APTR;
typedef char	       *STRPTR;
#define LIBF_DELEXP	0x08
struct Library {
	UBYTE  ln_pad[14];
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
void host_Remove(APTR);
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
};

/* -------- exec LVO calls ------------------------------------------ */
#define ALLOCMEM_E(size,fl) ({\
  register struct ExecBase * __p_sys __asm("a6") = *(struct ExecBase **)4;\
  register ULONG __p_size __asm("d0") = (ULONG)(size);\
  register ULONG __p_fl __asm("d1") = (ULONG)(fl);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_sys), "d"(__p_size), "d"(__p_fl)\
    : "a0","a1","fp0","fp1","cc","memory");\
  __p_res;})
#define FREEMEM_E(mem,sz) ({\
  register struct ExecBase * __p_sys __asm("a6") = *(struct ExecBase **)4;\
  register APTR __p_m __asm("a1") = (APTR)(mem);\
  register ULONG __p_s __asm("d0") = (ULONG)(sz);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
    : "+a"(__p_m), "+d"(__p_s)\
    : "a"(__p_sys)\
    : "d1","a0","fp0","fp1","cc","memory");})
#define REMOVENODE_E(node) ({\
  register struct ExecBase * __p_sys __asm("a6") = *(struct ExecBase **)4;\
  register APTR __p_n __asm("a1") = (APTR)(node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
    : "+a"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","a0","fp0","fp1","cc","memory");})

#ifdef HOST_TEST
#define REMOVENODE(x)		host_Remove(x)
#define ALLOCMEM(sz,f)		host_AllocMem(sz)
#define FREEMEM(p,s)		host_FreeMem(p,s)
#else
#define REMOVENODE(x)		REMOVENODE_E(x)
#define ALLOCMEM(sz,f)		ALLOCMEM_E(sz,f)
#define FREEMEM(p,s)		FREEMEM_E(p,s)
#endif

extern char xpkinfo[];

/* -------------------------------------------------------------- */
/* pack workmem							    */
/* -------------------------------------------------------------- */

#define WK_FREQ		0x0002		/* u16 freq[512]	    */
#define WK_HEAP		0x0402		/* u16 heap[257] 1-based   */
#define WK_PARENT	0x0606		/* s16 parent[512]	    */
#define WK_CHILD	0x0a06		/* u16 child[id*2+dir]     */
#define WK_CODES	0x120a		/* u32 code[256]	    */
#define WK_LENS		0x160a		/* u32 len[256]	    */
#define PWK_ALLOC	0x1a0e		/* alloc size (hdr+body)   */
#define PWK_BODY	0x1a0a		/* wiped size		    */

#define UWK_ALLOC	0x1004		/* unpack alloc	    */
#define UWK_FAST	0x0800		/* fast table offset	    */

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

/* heap sift-down: sift(i, size) -- faithful port			    */
static void sift(UBYTE *wk, UWORD i, UWORD size)
{
	UWORD half = size >> 1;
	while (i <= half) {
		UWORD c = i + i;			/* left child */
		UWORD f = FREQ(wk, HEAP(wk, c));	/* left freq  */
		UWORD t;
		if (c < size) {				/* right exists */
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

/* -48 PackReset: wipes 0x1a0a bytes upward from Sub[0]		    */
void XpksPackReset(struct XpkSubParams *xsp __asm("a0"))
{
	UBYTE *wk = xsp->xsp_Sub[0];
	ULONG i;
	if (!wk)
		return;
	for (i = 0; i < PWK_BODY / 4; i++)
		NWR32(wk + i * 4, 0);
}

/* -36 pack chunk							    */
LONG XpksPackChunk(struct XpkSubParams *xsp __asm("a0"),
		   struct HfmnBase *base __asm("a6"))
{
	UBYTE *wk;
	const UBYTE *in, *ip;
	UBYTE *out, *a4, *a3, *a1;
	ULONG inlen, nused, d0, d7;
	int i;

	if (!xsp->xsp_Sub[0]) {
		APTR m = ALLOCMEM(PWK_ALLOC, 0);
		if (!m)
			return -7;
		NWR32(m, PWK_ALLOC);
		xsp->xsp_Sub[0] = (UBYTE *)m + 4;
	}
	wk = xsp->xsp_Sub[0];
	XpksPackReset(xsp);

	in = xsp->xsp_InBuf;
	out = xsp->xsp_OutBuf;
	inlen = xsp->xsp_InLen;
	a4 = out + inlen;		/* output hard limit	    */

	/* histogram: 16-bit DBF counter, wraps on inlen==0	    */
	d0 = (inlen - 1) & 0xffff;
	ip = in;
	for (;;) {
		UWORD sym = *ip++;
		SFREQ(wk, sym, (UWORD)(FREQ(wk, sym) + 1));
		d0 = (d0 - 1) & 0xffff;
		if (d0 == 0xffff)
			break;
	}

	/* symbol list: descending sym order into heap[1..nused]    */
	nused = 0;
	{
		UWORD id;
		for (id = 0xff;; id--) {
			if (FREQ(wk, id))
				SHEAP(wk, ++nused, id);
			if (!id)
				break;
		}
	}

	d7 = nused >> 1;
	if (!d7) {
		/* single symbol: phantom sym-0 '0'-side sibling	    */
		UWORD s = HEAP(wk, 1);
		SFREQ(wk, 0x101, FREQ(wk, s));
		SPARENTP(wk, s, 0x0101);
		SPARENTP(wk, 0, 0xfeff);	/* -0x101	    */
	} else {
		/* heapify: sift(nused/2) .. sift(1)		    */
		d7--;
		for (i = (int)d7 + 1; i >= 1; i--)
			sift(wk, (UWORD)i, (UWORD)nused);
		/* merges: d7 = nused-1 .. 1			    */
		d7 = nused - 1;
		for (;;) {
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

	/* collect codes: walk parents leaf-up, accumulate LSB-first */
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

	/* emit tree + data						    */
	{
		ULONG acc = 1;		/* bit-32 sentinel	    */
		ULONG nbytes = 0;
		UWORD d1, cur, sym;
		SHORT p;

		a3 = out + 2;
#define EMIT(bit) do {						\
		ULONG __c = acc >> 31;				\
		acc = (acc << 1) | (bit);			\
		if (__c) {					\
			if (a3 >= a4)				\
				return -17;			\
			NWR32(a3, acc); a3 += 4; nbytes += 4;	\
			acc = 1;				\
		}						\
	} while (0)

		d1 = 0x101;
		for (;;) {
			cur = CHILD1(wk, d1);	/* LAB_0026	    */
			if (cur > 0x100) {		/* internal	    */
				EMIT(1);	/* LAB_0027	    */
				d1 = cur;
				continue;
			}
			for (;;) {			/* LAB_0028 leaves   */
				int k;
				sym = cur;
				/* '0' selector + sym bits0..7    */
				EMIT(0);
				for (k = 0; k < 8; k++)
					EMIT((sym >> k) & 1);
				for (;;) {		/* LAB_002A climb   */
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
				if (cur > 0x100) {	/* internal sib */
					EMIT(1);	/* LAB_0027	    */
					d1 = cur;
					break;		/* -> LAB_0026	    */
				}
				/* leaf sibling: emit it, climb again   */
			}
		}
tree_done:
		/* LAB_002C: ADDX pad -- X is always 1 on entry	    */
		{
			ULONG xf = 1;
			for (;;) {
				ULONG c = acc >> 31;
				acc = (acc << 1) | xf;
				xf = 0;
				if (c)
					break;
			}
		}
		if (a3 >= a4)
			return -17;
		NWR32(a3, acc);
		a3 += 4; nbytes += 4;
		NWR16(out, (UWORD)nbytes);

		xsp->xsp_OutLen = nbytes + 2;

		/* data: inlen word then variable-length codes	    */
		a1 = out + 2 + nbytes;
		NWR16(a1, (UWORD)inlen);
		a1 += 2;
		{
			ULONG d5 = 0;		/* data bitpos	    */
			ULONG d7c = (inlen - 1) & 0xffff;
			ip = in;
			for (;;) {
				ULONG sym = *ip++;
				ULONG c = CODES(wk, sym);
				ULONG l = (UBYTE)LENS(wk, sym);
				/* BFINS: code bit len-1 first	    */
				while (l--) {
					ULONG bp = d5 >> 3;
					if (c & (1UL << l))
						a1[bp] |= 1 << (7 - (d5 & 7));
					else
						a1[bp] &= ~(1 << (7 - (d5 & 7)));
					d5++;
				}
				if (a1 + (d5 >> 3) >= a4)
					return -17;
				d7c = (d7c - 1) & 0xffff;
				if (d7c == 0xffff)
					break;
			}
			xsp->xsp_OutLen += 5 + (d5 >> 3);
		}
#undef EMIT
	}
	return 0;
}

/* -------------------------------------------------------------- */
/* unpack								    */
/* -------------------------------------------------------------- */

/* node at byte offset off: {u16 slot0('1'), u16 slot1('0')}	    */
#define NODE0(wk,o)	NRD16((UBYTE *)(wk) + (o))
#define NODE1(wk,o)	NRD16((UBYTE *)(wk) + (o) + 2)
#define SNODE0(wk,o,v)	NWR16((UBYTE *)(wk) + (o), (v))
#define SNODE1(wk,o,v)	NWR16((UBYTE *)(wk) + (o) + 2, (v))
#define NLONG(wk,o)	NRD32((UBYTE *)(wk) + (o))
#define SNLONG(wk,o,v)	NWR32((UBYTE *)(wk) + (o), (v))
#define BKPTR(wk,o)	((LONG)NRD32((UBYTE *)(wk) + UWK_FAST + (o)))
#define SBKPTR(wk,o,v) NWR32((UBYTE *)(wk) + UWK_FAST + (o), (ULONG)(v))
#define FAST(wk,i)	((SHORT)NRD16((UBYTE *)(wk) + UWK_FAST + 2*(i)))

/* -54 unpack chunk							    */
LONG XpksUnpackChunk(struct XpkSubParams *xsp __asm("a0"),
		     struct HfmnBase *base __asm("a6"))
{
	UBYTE *wk, *a4;
	const UBYTE *a1;
	UBYTE *out;
	ULONG d3, d4, d5, d6, d7, d0;
	ULONG inlen;
	int idx;

	if (!xsp->xsp_Sub[0]) {
		APTR m = ALLOCMEM(UWK_ALLOC, 0);
		if (!m)
			return -7;
		NWR32(m, UWK_ALLOC);
		xsp->xsp_Sub[0] = (UBYTE *)m + 4;
	}
	wk = xsp->xsp_Sub[0];
	a4 = wk + UWK_FAST;			/* fast/backptr region */
	a1 = (const UBYTE *)xsp->xsp_InBuf + 2;
	out = xsp->xsp_OutBuf;

	d6 = 0; d7 = 0; d3 = 0; d4 = 0; d5 = 4;
	SNLONG(wk, 0, 0);				/* root slots = 0    */
	SBKPTR(wk, 0, -1);			/* root backptr	    */

#define NEXTBIT() ({						\
	int _b;							\
	if ((int)(d6 - 1) < 0) {				\
		d7 = NRD32(a1); a1 += 4; d6 = 31;		\
	} else							\
		d6--;						\
	_b = (int)(d7 >> 31);					\
	d7 <<= 1;						\
	_b; })

	for (;;) {
		SNLONG(wk, d5, 0);			/* clr node	    */
		SBKPTR(wk, d5, 0);			/* clr backptr	    */
		if (NEXTBIT()) {
			/* '1' -- internal child			    */
			if (!d3)
				SNODE0(wk, d4, d5);
			else
				SNODE1(wk, d4, d5);
			SBKPTR(wk, d5, d4);
			d4 = d5; d5 += 4;
			d3 = 0;
		} else {
			/* '0' -- leaf: 8 bits, first read = bit0	    */
			ULONG sym = 0xffffff00;
			int k;
			for (k = 0; k < 8; k++)
				sym |= (ULONG)NEXTBIT() << k;
			if (!d3) {
				SNODE0(wk, d4, d5);
				SBKPTR(wk, d5, d4);
				SNLONG(wk, d5, sym);
				d5 += 4;
				d3 = 1;
			} else {
				SNODE1(wk, d4, d5);
				SBKPTR(wk, d5, d4);
				SNLONG(wk, d5, sym);
				d5 += 4;
				/* climb to ancestor with free slot1   */
				for (;;) {
					d4 = BKPTR(wk, d4);
					if ((LONG)d4 < 0)
						goto trie_done;
					if (NODE1(wk, d4) == 0)
						break;
				}
			}
		}
	}
trie_done:

	/* fast table: walk the trie for each 10-bit prefix	    */
	{
		UBYTE *a0 = a4;
		ULONG d2 = 0;				/* idx*64	    */
		for (idx = 0; idx < 1024; idx++) {
			ULONG node = NLONG(wk, 0);
			UWORD dv = (UWORD)d2;
			int d1 = 9;
			UWORD d4w;
			for (;;) {
				UWORD c = dv & 0x8000;
				dv = (UWORD)(dv + dv);		/* next bit */
				if (c)				/* '1' -> slot0 */
					node = ((node & 0xffff) << 16)
					     | (node >> 16);
				d4w = (UWORD)node;
				node = NLONG(wk, d4w);
				if ((LONG)node < 0)
					break;			/* leaf	    */
				if (--d1 < 0)			/* deep	    */
					goto deep;
			}
			/* leaf: entry = {10-len, sym}		    */
			a0[0] = (UBYTE)d1;
			a0[1] = (UBYTE)node;
			a0 += 2;
			goto next;
		deep:
			NWR16(a0, (UWORD)(d4w - 0x800));
			a0 += 2;
		next:
			d2 += 0x40;
		}
	}

	/* decode stream: u16 treesize then u16 inlen then bits	    */
	a1 = (const UBYTE *)xsp->xsp_InBuf;
	inlen = NRD16(a1) & 0x1ff;			/* tree bytes	    */
	a1 += 2 + inlen;
	inlen = NRD16(a1); a1 += 2;			/* inlen	    */
	d5 = (inlen - 1) & 0xffff;
	{
		ULONG bitpos = 0;
		for (;;) {
			SHORT f;
			int k;
			/* BFEXTU 10 bits at bitpos			    */
			d0 = 0;
			for (k = 9; k >= 0; k--) {
				ULONG bp = bitpos + (9 - k);
				d0 |= ((ULONG)(a1[bp >> 3]
				        >> (7 - (bp & 7))) & 1) << k;
			}
			bitpos += 10;
			f = FAST(wk, d0);
			if (f >= 0) {
				*out++ = (UBYTE)f;
				bitpos -= (UWORD)f >> 8;
			} else {
				/* deep: one 32-bit window + trie walk    */
				ULONG node = NRD32(a4 + (SHORT)f);
				ULONG win = 0;
				for (k = 0; k < 32; k++) {
					ULONG bp = bitpos + k;
					win |= ((ULONG)(a1[bp >> 3]
					        >> (7 - (bp & 7))) & 1)
					       << (31 - k);
				}
				for (;;) {
					bitpos++;
					if (win & 0x80000000UL)
						node = ((node & 0xffff) << 16)
						     | (node >> 16);
					win <<= 1;
					node = NLONG(wk, (UWORD)node);
					if ((LONG)node < 0)
						break;
				}
				*out++ = (UBYTE)node;
			}
			d5 = (d5 - 1) & 0xffff;
			if (d5 == 0xffff)
				break;
		}
	}
	return 0;
#undef NEXTBIT
}

/* -30 PackerInfo							    */
char *XpksPackerInfo(struct XpkSubParams *xsp __asm("a0"),
		     struct HfmnBase *base __asm("a6"))
{
	return xpkinfo;
}

/* -42/-60 free the workmem (sized header at Sub[0]-4)		    */
LONG XpksPackFree(struct XpkSubParams *xsp __asm("a0"),
		  struct HfmnBase *base __asm("a6"))
{
	APTR sub = xsp->xsp_Sub[0];
	if (sub) {
		UBYTE *p = (UBYTE *)sub - 4;
		FREEMEM(p, NRD32(p));
	}
	return 0;
}

/* -------------------------------------------------------------- */
/* lifecycle							    */
/* -------------------------------------------------------------- */

struct Library *LibOpen(struct HfmnBase *b __asm("a6"))
{
	++b->lib.lib_OpenCnt;
	b->lib.lib_Flags &= ~LIBF_DELEXP;
	return (struct Library *)b;
}

static ULONG expunge_body(struct HfmnBase *b)
{
	ULONG seg = (ULONG)b->seglist;
	ULONG sz = b->lib.lib_NegSize + b->lib.lib_PosSize;
	UBYTE *p = (UBYTE *)b - b->lib.lib_NegSize;
	REMOVENODE(b);
	FREEMEM(p, sz);
	return seg;
}

LONG LibClose(struct HfmnBase *b __asm("a6"))
{
	if (--b->lib.lib_OpenCnt == 0 && (b->lib.lib_Flags & LIBF_DELEXP))
		return (LONG)expunge_body(b);
	return 0;
}

ULONG LibExpunge(struct HfmnBase *b __asm("a6"))
{
	if (b->lib.lib_OpenCnt) {
		b->lib.lib_Flags |= LIBF_DELEXP;
		return 0;
	}
	return expunge_body(b);
}
