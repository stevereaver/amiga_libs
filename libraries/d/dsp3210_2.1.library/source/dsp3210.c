/*
** dsp3210.library 2.1 (4.3.2021) — C reconstruction.
**
** AT&T DSP3210 big-endian COFF image loader.  Lifecycle, helpers and
** the -36 reloc engine live in dsp3210_lib.s (verbatim); this file
** holds the three API functions that are cleanly expressible in C:
**
**   -30  dsp_objsize(img,len)   validate COFF, return load size
**   -42  dsp_loadfile(name,x)   DOS-read file, load into descriptor
**   -48  dsp_unload(desc)       free a dsp_loadfile descriptor
**
** DSPBase:
**   +34  seglist (BPTR)
**   +38  unused
**   +42  dosbase (lazy-opened by dsp_opendos, closed on expunge)
**
** Loaded-descriptor block (allocated by dsp_loadfile):
**   -8   magic 0x32102011
**   -4   image size (bytes after header)
**    0   loaded/relocated image (CachePostDMA-flushed)
*/

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef long           LONG;
typedef void          *APTR;
typedef ULONG          BPTR;
typedef char          *STRPTR;

struct Library {
    APTR  ln_Succ, ln_Pred;
    UBYTE ln_Type, ln_Pri;
    STRPTR ln_Name;
    UBYTE lib_Flags, lib_pad;
    UWORD lib_NegSize, lib_PosSize;
    UWORD lib_Version, lib_Revision;
    STRPTR lib_IdString;
    ULONG lib_Sum;
    UWORD lib_OpenCnt;
};

struct DSPBase {
    struct Library lib;	/* 34 bytes */
    BPTR seglist;	/* +34 */
    ULONG pad;		/* +38 */
    APTR dosbase;	/* +42 */
};

#define MEMF_CLEAR	0x00010000
#define MEMF_PUBLIC	0x00000001
#define DSP_DESC_MAGIC	0x32102011
#define MODE_OLDFILE	1005
#define ACCESS_READ	(-2)
#define DMA_RDFROMRAM	0x800

/* exec calls — a6 saved, loaded from 4.w, restored (libbase sits in a6) */

static APTR ex_alloc(ULONG sz, ULONG fl)
{
    register ULONG _s __asm("d0") = sz;
    register ULONG _f __asm("d1") = fl;
    __asm volatile("movem.l a6,-(sp)\n\t"
	"movea.l 4.w,a6\n\t"
	"jsr a6@(-198)\n\t"			/* AllocMem */
	"movem.l (sp)+,a6"
	: "+d"(_s), "+d"(_f)
	:
	: "a0", "a1", "cc", "memory");
    return (APTR)_s;
}

static void ex_free(APTR p, ULONG sz)
{
    register APTR  _p __asm("a1") = p;
    register ULONG _s __asm("d0") = sz;
    __asm volatile("movem.l a6,-(sp)\n\t"
	"movea.l 4.w,a6\n\t"
	"jsr a6@(-210)\n\t"			/* FreeMem */
	"movem.l (sp)+,a6"
	: "+a"(_p), "+d"(_s)
	:
	: "d1", "a0", "cc", "memory");
}

static void ex_cpdma(APTR addr, ULONG len, ULONG fl)
{
    register APTR  _a __asm("a0") = addr;
    register ULONG _l __asm("d0") = len;
    register ULONG _f __asm("d1") = fl;
    __asm volatile("movem.l a6,-(sp)\n\t"
	"movea.l 4.w,a6\n\t"
	"jsr a6@(-642)\n\t"			/* CachePostDMA */
	"movem.l (sp)+,a6"
	: "+a"(_a), "+d"(_l), "+d"(_f)
	:
	: "a1", "cc", "memory");
}

/* dos calls — a6 saved, loaded from the dosbase operand, restored */

static BPTR dos_lock(STRPTR name, LONG mode, APTR db)
{
    register STRPTR _n __asm("d1") = name;
    register LONG   _m __asm("d2") = mode;
    register APTR   _b __asm("a1") = db;
    register BPTR   _r __asm("d0");
    __asm volatile("movem.l a6,-(sp)\n\t"
	"movea.l %3,a6\n\t"
	"jsr a6@(-84)\n\t"			/* Lock */
	"movem.l (sp)+,a6"
	: "=d"(_r), "+d"(_n), "+d"(_m), "+a"(_b)
	:
	: "a0", "cc", "memory");
    return _r;
}

static LONG dos_examine(BPTR lock, APTR fib, APTR db)
{
    register BPTR _l __asm("d1") = lock;
    register APTR _f __asm("d2") = fib;
    register APTR _b __asm("a1") = db;
    register LONG _r __asm("d0");
    __asm volatile("movem.l a6,-(sp)\n\t"
	"movea.l %3,a6\n\t"
	"jsr a6@(-102)\n\t"			/* Examine */
	"movem.l (sp)+,a6"
	: "=d"(_r), "+d"(_l), "+d"(_f), "+a"(_b)
	:
	: "a0", "cc", "memory");
    return _r;
}

static void dos_unlock(BPTR lock, APTR db)
{
    register BPTR _l __asm("d1") = lock;
    register APTR _b __asm("a1") = db;
    __asm volatile("movem.l a6,-(sp)\n\t"
	"movea.l %1,a6\n\t"
	"jsr a6@(-90)\n\t"			/* UnLock */
	"movem.l (sp)+,a6"
	: "+d"(_l), "+a"(_b)
	:
	: "d0", "a0", "cc", "memory");
}

static BPTR dos_open(STRPTR name, LONG mode, APTR db)
{
    register STRPTR _n __asm("d1") = name;
    register LONG   _m __asm("d2") = mode;
    register APTR   _b __asm("a1") = db;
    register BPTR   _r __asm("d0");
    __asm volatile("movem.l a6,-(sp)\n\t"
	"movea.l %3,a6\n\t"
	"jsr a6@(-30)\n\t"			/* Open */
	"movem.l (sp)+,a6"
	: "=d"(_r), "+d"(_n), "+d"(_m), "+a"(_b)
	:
	: "a0", "cc", "memory");
    return _r;
}

static LONG dos_read(BPTR fh, APTR buf, LONG len, APTR db)
{
    register BPTR _h __asm("d1") = fh;
    register APTR _p __asm("d2") = buf;
    register LONG _l __asm("d3") = len;
    register APTR _b __asm("a1") = db;
    register LONG _r __asm("d0");
    __asm volatile("movem.l a6,-(sp)\n\t"
	"movea.l %4,a6\n\t"
	"jsr a6@(-42)\n\t"			/* Read */
	"movem.l (sp)+,a6"
	: "=d"(_r), "+d"(_h), "+d"(_p), "+d"(_l), "+a"(_b)
	:
	: "a0", "cc", "memory");
    return _r;
}

static void dos_close(BPTR fh, APTR db)
{
    register BPTR _h __asm("d1") = fh;
    register APTR _b __asm("a1") = db;
    __asm volatile("movem.l a6,-(sp)\n\t"
	"movea.l %1,a6\n\t"
	"jsr a6@(-36)\n\t"			/* Close */
	"movem.l (sp)+,a6"
	: "+d"(_h), "+a"(_b)
	:
	: "d0", "a0", "cc", "memory");
}

extern void dsp_opendos(void);		/* asm: lazy OpenLibrary, a6 = base */

/* big-endian field reads — COFF is BE, fields may be unaligned */
static ULONG rdbe32(const UBYTE *p)
{
    return ((ULONG)p[0] << 24) | ((ULONG)p[1] << 16) |
	   ((ULONG)p[2] << 8) | (ULONG)p[3];
}

/*
** -30: dsp_objsize — validate a DSP3210 COFF image in memory.
**   a0 = image, d0 = image length.
** returns bytes needed for the loaded image, or -1 (bad magic/bounds)
** or -2 (unknown section type).
*/
LONG dsp_objsize(register UBYTE *img __asm("a0"),
		 register ULONG len __asm("d0"))
{
    ULONG total;
    UWORD nscns, i;
    const UBYTE *scn;
    ULONG flags, size;

    if (*(UWORD *)img != 0x166)			/* f_magic */
	return -1;
    if (*(ULONG *)(img + 8) +			/* f_symptr */
	(ULONG)*(ULONG *)(img + 12) * 18 > len)	/* f_nsyms*18 */
	return -1;
    nscns = *(UWORD *)(img + 2);		/* f_nscns */
    if (!nscns)
	return -1;
    scn = img + 20 + *(UWORD *)(img + 16);	/* + f_opthdr */
    total = 0;
    for (i = nscns; i; i--) {
	flags = rdbe32(scn + 36);		/* s_flags */
	if (flags != 0x20 && flags != 0x40 && flags != 0x80)
	    return -2;
	size = rdbe32(scn + 16);		/* s_size */
	total += (size + 3) & ~3UL;
	scn += 40;
    }
    return (LONG)total;
}

/*
** -42: dsp_loadfile — load a DSP COFF file from disk and build the
** loaded image descriptor.
**   a0 = filename, a1 = (passed through to loadimg's dead a2 arg),
**   a6 = base.
** returns pointer to the loaded image (descriptor+8), or NULL.
** On any failure the partial allocations are released.
*/
APTR dsp_loadfile(register STRPTR name __asm("a0"),
		  register APTR xarg __asm("a1"),
		  register struct DSPBase *b __asm("a6"))
{
    APTR fib, buf, desc;
    BPTR lock, fh;
    LONG fsize, need, err;
    APTR img;

    dsp_opendos();
    if (!b->dosbase)
	return (APTR)0;

    fib = ex_alloc(260, MEMF_PUBLIC | MEMF_CLEAR);	/* FileInfoBlock */
    if (!fib)
	return (APTR)0;

    lock = dos_lock(name, ACCESS_READ, b->dosbase);
    if (!lock) {
	ex_free(fib, 260);
	return (APTR)0;
    }
    dos_examine(lock, fib, b->dosbase);	/* result unchecked (as shipped) */
    dos_unlock(lock, b->dosbase);
    fsize = *(LONG *)((UBYTE *)fib + 124);	/* fib_Size */
    ex_free(fib, 260);

    buf = ex_alloc(fsize, MEMF_PUBLIC | MEMF_CLEAR);
    if (!buf)
	return (APTR)0;

    fh = dos_open(name, MODE_OLDFILE, b->dosbase);
    if (!fh)
	goto freebuf;
    if (dos_read(fh, buf, fsize, b->dosbase) != fsize) {
	dos_close(fh, b->dosbase);
	goto freebuf;
    }
    dos_close(fh, b->dosbase);

    need = dsp_objsize(buf, fsize);
    if (need < 0)
	goto freebuf;

    desc = ex_alloc(need + 8, MEMF_PUBLIC | MEMF_CLEAR);
    if (!desc)
	goto freebuf;

    *(ULONG *)desc = DSP_DESC_MAGIC;
    *(ULONG *)((UBYTE *)desc + 4) = need;
    img = (UBYTE *)desc + 8;

    /* a0=image, a1=dest, a2=xarg (dead), d0=fsize */
    {
	register UBYTE *_i __asm("a0") = buf;
	register APTR  _d __asm("a1") = img;
	register APTR  _x __asm("a2") = xarg;
	register ULONG _l __asm("d0") = fsize;
	register LONG  _r __asm("d0");
	__asm volatile("jsr _dsp_loadimg"
	    : "=d"(_r), "+a"(_i), "+a"(_d), "+a"(_x)
	    : "d"(_l)
	    : "d1", "d2", "d3", "d4", "d5", "d6", "d7",
	      "a3", "a4", "a5", "a6", "cc", "memory");
	err = _r;
    }

    ex_free(buf, fsize);
    if (err) {
	ex_free(desc, need + 8);
	return (APTR)0;
    }
    ex_cpdma(img, need, DMA_RDFROMRAM);	/* flush for DSP reads */
    return img;

freebuf:
    ex_free(buf, fsize);
    return (APTR)0;
}

/*
** -48: dsp_unload — free a descriptor returned by dsp_loadfile.
**   a0 = image pointer (descriptor+8).  Silently ignores misaligned
**   or bad-magic pointers, matching the shipped checks.
*/
void dsp_unload(register UBYTE *img __asm("a0"))
{
    UBYTE *blk = img - 8;

    if (((ULONG)blk & 3) == 0 && *(ULONG *)blk == DSP_DESC_MAGIC) {
	ULONG sz = *(ULONG *)(blk + 4) + 8;
	ex_free(blk, sz);
    }
}
