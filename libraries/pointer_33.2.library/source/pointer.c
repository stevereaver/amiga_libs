/*
**	pointer.library 33.2 -- reconstructed implementation
**	"PointerLibrary 33.2 (5 Jan 1991)"
**
**	NuPointer busy-pointer library.  Init stores SysBase at lib+0x46
**	(pd+0x14), opens intuition v33 and loads
**	SYS:Prefs/presets/BusyPointer.ilbm via dos+iffparse into a
**	24-byte spec {image, height, width, xoff, yoff, bodysize}; on any
**	failure it falls back to an embedded 16x16 chip-mem bitmap.
**
**	Vectors: -30 SetPointer(window) applies the current spec,
**	-36 loads a spec from an ILBM file, -42 frees a spec.
**
**	The 0x8a-byte library base holds the Library struct, a seglist
**	slot at +0x22, and a 0x50-byte block copied from the data hunk
**	at init (pd at lib+0x32).  The dos/iffparse base slots live at
**	pd+0x50/+0x54 -- past the copied block, written per call.
*/

#ifdef HOST_TEST
#include <stdint.h>
typedef uint8_t		UBYTE;
typedef uint16_t	UWORD;
typedef uint32_t	ULONG;
typedef int16_t		SHORT;
typedef int32_t		LONG;
typedef void	       *APTR;
typedef char	       *STRPTR;
#define __asm(x)
struct Library {
	UBYTE  ln_pad[14];	/* Node: succ,pred,type,pri,name   */
	UBYTE  lib_Flags;	/* +14			     */
	UBYTE  lib_pad;		/* +15			     */
	UWORD  lib_NegSize;	/* +16			     */
	UWORD  lib_PosSize;	/* +18			     */
	UWORD  lib_Version;	/* +20			     */
	UWORD  lib_Revision;	/* +22			     */
	ULONG  lib_IdString;	/* +24			     */
	ULONG  lib_Sum;		/* +28			     */
	UWORD  lib_OpenCnt;	/* +32			     */
};
#else
#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/memory.h>
#endif

/* -------- runtime data block (copied into lib+0x32 at init) -------- */

struct PtrData {
	ULONG	pd_pad;			/* +0x00		     */
	ULONG	pd_dataSize;		/* +0x04 InitTable copy	     */
	APTR	pd_funcTab;		/* +0x08		     */
	ULONG	pd_dataTab;		/* +0x0c		     */
	APTR	pd_initFunc;		/* +0x10		     */
	APTR	pd_exec;		/* +0x14 ExecBase	     */
	APTR	pd_intuition;		/* +0x18 intuition.library   */
	ULONG	pd_spec[6];		/* +0x1c embedded spec	     */
	ULONG  *pd_cur;			/* +0x34 current spec	     */
	ULONG	pd_props[6];		/* +0x38 iff prop list	     */
	/* +0x50 is past the copied block; runtime-only slots */
	APTR	pd_dos;			/* +0x50 dos.library	     */
	APTR	pd_iff;			/* +0x54 iffparse.library    */
};

#define PD(b)	((struct PtrData *)((UBYTE *)(b) + 0x32))
#define LIBSEG(b) (*(APTR *)((UBYTE *)(b) + 0x22))

/* spec layout: [0]=image [1]=height [2]=width [3]=xoff [4]=yoff
   [5]=bodysize (allocation size of [0], chunk size + 8)        */

struct ContextNode {
	ULONG	cn_pad[2];
	LONG	cn_ID;			/* +8			     */
	LONG	cn_Type;		/* +12			     */
	LONG	cn_Size;		/* +16			     */
	LONG	cn_Scan;		/* +20			     */
};

struct StoredProperty {
	LONG	sp_Size;
	APTR	sp_Data;
};

#define ID_ILBM	0x494c424d
#define ID_FORM	0x464f524d
#define ID_BODY	0x424f4459
#define ID_BMHD	0x424d4844
#define ID_CMAP	0x434d4150
#define ID_GRAB	0x47524142
#define ID_CRNG	0x43524e47

/* -------- exec LVO calls ------------------------------------------- */
#define OPENLIB(name,ver,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register STRPTR __p_n __asm("a1") = (STRPTR)(name);\
  register ULONG __p_v __asm("d0") = (ULONG)(ver);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-552:W)\n"\
    : "=r"(__p_res), "+a"(__p_n)\
    : "a"(__p_sys), "d"(__p_v)\
    : "d1","a0","cc","memory");\
  __p_res; })

#define CLOSELIB(lib,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register APTR __p_l __asm("a1") = (APTR)(lib);\
  __asm volatile ("jsr %/a6@(-414:W)\n"\
    : "+a"(__p_l)\
    : "a"(__p_sys)\
    : "d0","d1","a0","cc","memory"); })

#define ALLOCMEM(size,fl,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register ULONG __p_size __asm("d0") = (ULONG)(size);\
  register ULONG __p_fl __asm("d1") = (ULONG)(fl);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
    : "=r"(__p_res)\
    : "a"(__p_sys), "d"(__p_size), "d"(__p_fl)\
    : "a0","a1","cc","memory");\
  __p_res; })

#define FREEMEM(mem,sz,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register APTR __p_m __asm("a1") = (APTR)(mem);\
  register ULONG __p_s __asm("d0") = (ULONG)(sz);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
    : "+a"(__p_m), "+d"(__p_s)\
    : "a"(__p_sys)\
    : "d1","a0","cc","memory"); })

#define REMOVENODE(node,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register APTR __p_n __asm("a1") = (APTR)(node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
    : "+a"(__p_n)\
    : "a"(__p_sys)\
    : "d0","d1","a0","cc","memory"); })

/* -------- dos LVO calls -------------------------------------------- */
#define DOSOPEN(name,mode,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register STRPTR __p_n __asm("d1") = (STRPTR)(name);\
  register ULONG __p_m __asm("d2") = (ULONG)(mode);\
  register ULONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-30:W)\n"\
    : "=r"(__p_res), "+d"(__p_n), "+d"(__p_m)\
    : "a"(__p_sys)\
    : "a0","a1","cc","memory");\
  __p_res; })

#define DOSCLOSE(fh,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register ULONG __p_f __asm("d1") = (ULONG)(fh);\
  __asm volatile ("jsr %/a6@(-36:W)\n"\
    : "+d"(__p_f)\
    : "a"(__p_sys)\
    : "d0","a0","a1","cc","memory"); })

/* -------- iffparse LVO calls ----------------------------------------
   register conventions vary per call; the generic forms below take
   the iff handle in a0 and additional args in d0/d1/a1.               */
#define IFFA0(n,iff,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register APTR __p_i __asm("a0") = (APTR)(iff);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-" #n ":W)\n"\
    : "=r"(__p_res), "+a"(__p_i)\
    : "a"(__p_sys)\
    : "d1","a1","cc","memory");\
  __p_res; })

#define IFFA0D0(n,iff,v,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register APTR __p_i __asm("a0") = (APTR)(iff);\
  register LONG __p_v __asm("d0") = (LONG)(v);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-" #n ":W)\n"\
    : "=r"(__p_res), "+a"(__p_i)\
    : "a"(__p_sys), "d"(__p_v)\
    : "d1","a1","cc","memory");\
  __p_res; })

#define IFFCHUNK(n,iff,t,id,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register APTR __p_i __asm("a0") = (APTR)(iff);\
  register ULONG __p_t __asm("d0") = (ULONG)(t);\
  register ULONG __p_i2 __asm("d1") = (ULONG)(id);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-" #n ":W)\n"\
    : "=r"(__p_res), "+a"(__p_i)\
    : "a"(__p_sys), "d"(__p_t), "d"(__p_i2)\
    : "a1","cc","memory");\
  __p_res; })

#define PROPCHUNKS(iff,props,n,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register APTR __p_i __asm("a0") = (APTR)(iff);\
  register APTR __p_p __asm("a1") = (APTR)(props);\
  register LONG __p_n __asm("d0") = (LONG)(n);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-120:W)\n"\
    : "=r"(__p_res), "+a"(__p_i), "+a"(__p_p)\
    : "a"(__p_sys), "d"(__p_n)\
    : "d1","cc","memory");\
  __p_res; })

#define READRECS(iff,buf,rsz,nr,sbase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(sbase);\
  register APTR __p_i __asm("a0") = (APTR)(iff);\
  register APTR __p_b __asm("a1") = (APTR)(buf);\
  register ULONG __p_r __asm("d0") = (ULONG)(rsz);\
  register ULONG __p_n __asm("d1") = (ULONG)(nr);\
  __asm volatile ("jsr %/a6@(-72:W)\n"\
    : "+d"(__p_r), "+d"(__p_n), "+a"(__p_i), "+a"(__p_b)\
    : "a"(__p_sys)\
    : "cc","memory");\
  __p_r; })

/* -------- intuition LVO call ---------------------------------------- */
#define SETPOINTER(win,img,h,w,xo,yo,ibase) ({\
  register APTR __p_sys __asm("a6") = (APTR)(ibase);\
  register APTR __p_w __asm("a0") = (APTR)(win);\
  register APTR __p_i __asm("a1") = (APTR)(img);\
  register ULONG __p_h __asm("d0") = (ULONG)(h);\
  register ULONG __p_wd __asm("d1") = (ULONG)(w);\
  register ULONG __p_x __asm("d2") = (ULONG)(xo);\
  register ULONG __p_y __asm("d3") = (ULONG)(yo);\
  __asm volatile ("jsr %/a6@(-270:W)\n"\
    : "+a"(__p_w), "+a"(__p_i), "+d"(__p_h), "+d"(__p_wd),\
      "+d"(__p_x), "+d"(__p_y)\
    : "a"(__p_sys)\
    : "cc","memory"); })

#ifdef HOST_TEST
/* host stubs: the macros above still emit m68k jsr sequences, so
   under HOST_TEST they are replaced by plain C calls. */
LONG host_OpenLibrary(STRPTR, ULONG, APTR);
void host_CloseLibrary(APTR, APTR);
APTR host_AllocMem(ULONG, ULONG);
void host_FreeMem(APTR, ULONG);
void host_Remove(APTR);
ULONG host_DosOpen(STRPTR, ULONG, APTR);
void host_DosClose(ULONG, APTR);
LONG host_IFFA0(LONG, APTR, APTR);
LONG host_IFFA0D0(LONG, APTR, LONG, APTR);
LONG host_IFFChunk(LONG, APTR, ULONG, ULONG, APTR);
LONG host_PropChunks(APTR, APTR, LONG, APTR);
LONG host_ReadRecs(APTR, APTR, ULONG, ULONG, APTR);
void host_SetPointer(APTR, APTR, ULONG, ULONG, ULONG, ULONG, APTR);

#undef OPENLIB
#define OPENLIB(n,v,b)		host_OpenLibrary(n,v,b)
#undef CLOSELIB
#define CLOSELIB(l,b)		host_CloseLibrary(l,b)
#undef ALLOCMEM
#define ALLOCMEM(s,f,b)		host_AllocMem(s,f)
#undef FREEMEM
#define FREEMEM(m,s,b)		host_FreeMem(m,s)
#undef REMOVENODE
#define REMOVENODE(n,b)		host_Remove(n)
#undef DOSOPEN
#define DOSOPEN(n,m,b)		host_DosOpen(n,m,b)
#undef DOSCLOSE
#define DOSCLOSE(f,b)		host_DosClose(f,b)
#undef IFFA0
#define IFFA0(n,i,b)		host_IFFA0(n,i,b)
#undef IFFA0D0
#define IFFA0D0(n,i,v,b)	host_IFFA0D0(n,i,v,b)
#undef IFFCHUNK
#define IFFCHUNK(n,i,t,id,b)	host_IFFChunk(n,i,t,id,b)
#undef PROPCHUNKS
#define PROPCHUNKS(i,p,n,b)	host_PropChunks(i,p,n,b)
#undef READRECS
#define READRECS(i,buf,r,n,b)	host_ReadRecs(i,buf,r,n,b)
#undef SETPOINTER
#define SETPOINTER(w,i,h,wd,x,y,b) host_SetPointer(w,i,h,wd,x,y,b)
#endif

#ifdef HOST_TEST
extern APTR host_SysBase;
#define SYSBASE()	host_SysBase
#else
#define SYSBASE()	(*(APTR *)4)
#endif

extern const ULONG datablk[];
extern const char libname[];
extern const char idstr[];

LONG PtrDepsInit(struct Library *b __asm("a6"));
ULONG *PtrLoadSpec(STRPTR path __asm("a0"),
		   struct Library *b __asm("a6"));
void PtrFreeSpec(ULONG *spec __asm("a0"),
		 struct Library *b __asm("a6"));
ULONG LibExpunge(struct Library *b __asm("a6"));

/* ------------------------------------------------------------------ */
/* LibInit -- a0 = seglist, d0 = libbase.
** Fills the Library fields manually, copies the 0x50-byte data block
** into lib+0x32, applies the fixup list, then runs the dep init.
** Returns the libbase or 0.                                       */
/* ------------------------------------------------------------------ */
struct Library *LibInit(APTR seg __asm("a0"),
			struct Library *b __asm("d0"))
{
	ULONG *dst = (ULONG *)((UBYTE *)b + 0x32);
	ULONG *fix;
	LONG n;
	int i;

	LIBSEG(b) = seg;
	((UBYTE *)b)[8] = 9;			/* ln_Type NT_LIBRARY   */
	*(APTR *)((UBYTE *)b + 10) = (APTR)libname;
	((UBYTE *)b)[14] = 6;			/* lib_Flags	    */
	*(UWORD *)((UBYTE *)b + 20) = 33;	/* lib_Version	    */
	*(UWORD *)((UBYTE *)b + 22) = 2;	/* lib_Revision	    */
	*(APTR *)((UBYTE *)b + 24) = (APTR)idstr;

	for (i = 0; i < 0x14; i++)
		dst[i] = datablk[i];
	fix = (ULONG *)&datablk[0x14];
	n = *fix++;
	while (n-- > 0)
		*(ULONG *)((UBYTE *)dst + *fix++) += (ULONG)dst;

	if (!(PtrDepsInit(b) & 0xffff))
		return 0;
	return b;
}

/* ------------------------------------------------------------------ */
/* PtrDepsInit -- a6 = libbase.  Stores ExecBase, opens intuition v33  */
/* and loads the preset ILBM; falls back to the embedded spec.
** Returns 0/1.                                                     */
/* ------------------------------------------------------------------ */
LONG PtrDepsInit(struct Library *b __asm("a6"))
{
	struct PtrData *pd = PD(b);
	APTR sys = SYSBASE();
	ULONG *spec;

	pd->pd_exec = sys;
	pd->pd_intuition = OPENLIB("intuition.library", 33, sys);
	if (!pd->pd_intuition)
		return 0;
	spec = PtrLoadSpec("SYS:Prefs/presets/BusyPointer.ilbm", b);
	pd->pd_cur = spec ? spec : pd->pd_spec;
	return 1;
}

/* ------------------------------------------------------------------ */
/* -30: PtrSetPointer -- a0 = window.  Applies the current spec via    */
/* intuition's SetPointer.                                           */
/* ------------------------------------------------------------------ */
void PtrSetPointer(APTR win __asm("a0"),
		   struct Library *b __asm("a6"))
{
	struct PtrData *pd = PD(b);
	ULONG *spec = pd->pd_cur;

	SETPOINTER(win, (APTR)spec[0], spec[1], spec[2], spec[3],
		   spec[4], pd->pd_intuition);
}

/* ------------------------------------------------------------------ */
/* -36: PtrLoadSpec -- a0 = IFF pathname.  Loads a BusyPointer-style   */
/* ILBM into a fresh 24-byte spec.  Returns the spec or 0 on failure. */
/* ------------------------------------------------------------------ */
ULONG *PtrLoadSpec(STRPTR path __asm("a0"),
		   struct Library *b __asm("a6"))
{
	struct PtrData *pd = PD(b);
	ULONG *spec = 0;
	APTR sys = pd->pd_exec;
#ifdef HOST_TEST
	APTR iff = 0;
#else
	APTR iff;	/* original leaves this uninitialized until
			   AllocIFF -- early exits read stale stack    */
#endif
	LONG r;
	struct ContextNode *cn;
	struct StoredProperty *prop;
	UBYTE *bmhd;

	pd->pd_dos = OPENLIB("dos.library", 0, sys);
	if (!pd->pd_dos)
		goto out;
	pd->pd_iff = OPENLIB("iffparse.library", 0, sys);
	if (!pd->pd_iff)
		goto out;
	spec = ALLOCMEM(24, 1, sys);		/* MEMF_PUBLIC	    */
	if (!spec)
		goto out;
	iff = (APTR)IFFA0(30, iff, pd->pd_iff);	/* AllocIFF	    */
	if (!iff) {
		spec = 0;
		goto out;
	}
	*(ULONG *)iff = DOSOPEN(path, 0x3ed, pd->pd_dos); /* iff_Stream  */
	if (!*(ULONG *)iff) {
		spec = 0;
		goto out;
	}
	IFFA0(234, iff, pd->pd_iff);		/* InitIFFasDOS    */
	r = PROPCHUNKS(iff, pd->pd_props, 3, pd->pd_iff);
	if (r)
		goto out;
	r = IFFCHUNK(126, iff, ID_ILBM, ID_BODY, pd->pd_iff); /* StopChunk  */
	if (r)
		goto out;
	r = IFFCHUNK(138, iff, ID_ILBM, ID_CRNG, pd->pd_iff); /* Collection */
	if (r)
		goto out;
	r = IFFCHUNK(150, iff, ID_ILBM, ID_FORM, pd->pd_iff); /* StopOnExit */
	if (r)
		goto out;
	r = IFFA0D0(36, iff, 0, pd->pd_iff);	/* OpenIFF IFFF_READ  */
	if (r)
		goto out;
	r = IFFA0D0(42, iff, 1, pd->pd_iff);	/* ParseIFF step	    */
	if (r)
		goto out;
	cn = (struct ContextNode *)IFFA0(174, iff, pd->pd_iff);
	if (!cn) {
		spec = 0;
		goto out;
	}
	if (cn->cn_ID != ID_FORM || cn->cn_Type != ID_ILBM) {
		spec = 0;
		/* original still runs the BODY loop below, storing
		   through a null spec pointer -- keep the write target
		   hidden from the optimizer so the stores are emitted */
		__asm volatile("" : "+r"(spec));
	}
	while (r == 0) {
		r = IFFA0D0(42, iff, 0, pd->pd_iff);	/* ParseIFF scan   */
		if (r)
			break;
		prop = (struct StoredProperty *)
			IFFCHUNK(156, iff, ID_ILBM, ID_BMHD, pd->pd_iff);
		if (!prop) {
			spec = 0;
			break;
		}
		bmhd = prop->sp_Data;
		if (bmhd[10]) {			/* compression	    */
			spec = 0;
			break;
		}
		spec[2] = *(UWORD *)bmhd;
		spec[1] = *(UWORD *)(bmhd + 2);
		spec[3] = 0;
		spec[4] = 0;
		prop = (struct StoredProperty *)
			IFFCHUNK(156, iff, ID_ILBM, ID_GRAB, pd->pd_iff);
		if (prop) {
			spec[3] = -(LONG)*(UWORD *)prop->sp_Data;
			spec[4] = -(LONG)*((UWORD *)prop->sp_Data + 1);
		}
		cn = (struct ContextNode *)IFFA0(174, iff, pd->pd_iff);
		spec[5] = cn->cn_Size + 8;
		spec[0] = (ULONG)ALLOCMEM(spec[5], 2, sys); /* MEMF_CHIP  */
		if (!spec[0]) {
			spec = 0;
			break;
		}
		READRECS(iff, (UBYTE *)spec[0] + 4, (ULONG)cn->cn_Size >> 1,
			 2, pd->pd_iff);
	}

out:
	if (iff) {
		IFFA0(48, iff, pd->pd_iff);		/* CloseIFF	    */
		if (*(ULONG *)iff)
			DOSCLOSE(*(ULONG *)iff, pd->pd_dos);
		IFFA0(54, iff, pd->pd_iff);		/* FreeIFF	    */
	}
	if (pd->pd_iff)
		CLOSELIB(pd->pd_iff, sys);
	if (pd->pd_dos)
		CLOSELIB(pd->pd_dos, sys);
	return spec;
}

/* ------------------------------------------------------------------ */
/* -42: PtrFreeSpec -- a0 = spec.  Frees the image alloc and the       */
/* 24-byte spec.                                                     */
/* ------------------------------------------------------------------ */
void PtrFreeSpec(ULONG *spec __asm("a0"),
		 struct Library *b __asm("a6"))
{
	struct PtrData *pd = PD(b);
	APTR sys = pd->pd_exec;

	if (spec[0])
		FREEMEM((APTR)spec[0], spec[5], sys);
	FREEMEM(spec, 24, sys);
}

/* ------------------------------------------------------------------ */
/* PtrFreeDeps -- closes intuition and frees the current spec if it   */
/* is not the embedded default.                                       */
/* ------------------------------------------------------------------ */
void PtrFreeDeps(struct Library *b __asm("a6"))
{
	struct PtrData *pd = PD(b);
	APTR sys = pd->pd_exec;

	if (pd->pd_intuition) {
		CLOSELIB(pd->pd_intuition, sys);
		pd->pd_intuition = 0;
	}
	if (pd->pd_cur != pd->pd_spec)
		PtrFreeSpec(pd->pd_cur, b);
}

/* ------------------------------------------------------------------ */
/* -6: Open                                                           */
/* ------------------------------------------------------------------ */
struct Library *LibOpen(struct Library *b __asm("a6"))
{
	b->lib_OpenCnt++;
	((UBYTE *)b)[14] &= ~8;			/* clear LIBF_DELEXP   */
	return b;
}

/* ------------------------------------------------------------------ */
/* -12: Close                                                         */
/* ------------------------------------------------------------------ */
ULONG LibClose(struct Library *b __asm("a6"))
{
	ULONG r = 0;

	if (--b->lib_OpenCnt == 0 && (((UBYTE *)b)[14] & 8))
		r = LibExpunge(b);
	return r;
}

/* ------------------------------------------------------------------ */
/* -18: Expunge                                                       */
/* ------------------------------------------------------------------ */
ULONG LibExpunge(struct Library *b __asm("a6"))
{
	ULONG seg = 0;

	((UBYTE *)b)[14] |= 8;			/* set LIBF_DELEXP     */
	if (b->lib_OpenCnt == 0) {
		ULONG neg = b->lib_NegSize;
		ULONG pos = b->lib_PosSize;
		UBYTE *start;
		APTR sys = SYSBASE();

		PtrFreeDeps(b);
		seg = (ULONG)LIBSEG(b);
		REMOVENODE(b, sys);
		start = (UBYTE *)b - neg;
		FREEMEM(start, neg + pos, sys);
	}
	return seg;
}
