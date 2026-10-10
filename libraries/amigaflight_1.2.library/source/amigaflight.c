/*
**	amigaflight.c -- amigaflight.library "AmigaFlight BETA 1.2
**	(12.06.94)" C reconstruction of the shipped binary.
**
**	A small console hex-I/O toolkit for the AmigaFlight
**	debugger.  All I/O vectors take a dos filehandle in a1 and
**	route through dos.library (FGetC/WaitForChar/FPutC/FPuts/
**	Flush -- Flush after EVERY FPutC, as shipped).
**
**	The hex-parse vectors that signal errors via the carry flag
**	(AFHexValue/AFGetChar/AFGetHexChar/AFReadHex) live in
**	amigaflight_lib.s to preserve the register contract.
**
**	Public API (all a1 = handle):
**	  -30 AFHexValue(c)      hex char -> nibble, C flag on bad
**	  -36 AFNewLine()        emits LF then CR (reversed order!)
**	  -42 AFEnterAddress()   prompts + reads hex addr -> a0
**	  -48 AFGetChar()        FGetC, maps 0x9b (CSI) -> 0
**	  -54 AFGetHexChar()     read+echo+uppercase+hexval
**	  -60 AFCharAvail()      WaitForChar(handle,1)
**	  -66 AFReadHex()        digits -> d1 value/d2 count/d0 term
**	  -72 AFPutChar(c)       FPutC+Flush
**	  -78 AFPutNibble(n)     one hex digit
**	  -84 AFPutByte(b)       two hex digits
**	  -90 AFPutWord(w)       four hex digits
**	  -96 AFPutLong(l)       eight hex digits
**	  -102 AFPutString(s)    FPuts+Flush (str in d2!)
**	  -108 AFPutSpace()      one space
**	  -114 AFPutSpaces(n)    n spaces
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>		/* BPTR */

struct AFBase			/* dataSize 0x30		    */
{
    struct Library af_Lib;	/* 0x00				    */
    ULONG  af_pad22;		/* 0x22				    */
    struct ExecBase *af_Sys;	/* 0x24 SysBase		    */
    struct Library *af_Dos;	/* 0x28 dos.library base	    */
    BPTR   af_SegList;		/* 0x2c				    */
};

extern const char s_doslib[];	/* "dos.library" */
extern const char s_prompt[];	/* "  Enter Address : " */
extern const char s_badaddr[];	/* "  *** INVALID ADDRESS *** " */

/* asm vectors (amigaflight_lib.s) */
LONG AFReadHex(void *handle __asm("a1"), struct AFBase *base __asm("a6"));

/* ------------------------------------------------------------------ */
/* Exec / dos LVO calls						  */
/* ------------------------------------------------------------------ */

#define __OpenLibrary(__sys, ___name, ___ver) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register const char * __p_name __asm("a1") = (const char *)(___name);\
  register ULONG __p_ver __asm("d0") = (ULONG)(___ver);\
  register void * __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-552:W)\n"\
		   : "=r"(__p_res)\
		   : "a"(__p_name), "d"(__p_ver), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );\
  __p_res;})

#define __CloseLibrary(__sys, ___lib) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_lib __asm("a1") = (void *)(___lib);\
  __asm volatile ("jsr %/a6@(-414:W)\n"\
		   : : "a"(__p_lib), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __FreeMem(__sys, ___blk, ___size) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_blk __asm("a1") = (void *)(___blk);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

#define __WaitForChar(__dos, ___fh, ___tmo) ({\
  register void * __p_dos __asm("a6") = (void *)(__dos);\
  register LONG __p_fh __asm("d1") = (LONG)(___fh);\
  register LONG __p_tmo __asm("d2") = (LONG)(___tmo);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-204:W)\n"\
		   : "=r"(__p_res)\
		   : "d"(__p_fh), "d"(__p_tmo), "a"(__p_dos)\
		   : "cc", "memory", "a0", "a1" );\
  __p_res;})

#define __FPutC(__dos, ___fh, ___ch) ({\
  register void * __p_dos __asm("a6") = (void *)(__dos);\
  register LONG __p_fh __asm("d1") = (LONG)(___fh);\
  register LONG __p_ch __asm("d2") = (LONG)(___ch);\
  __asm volatile ("jsr %/a6@(-312:W)\n"\
		   : : "d"(__p_fh), "d"(__p_ch), "a"(__p_dos)\
		   : "cc", "memory", "d0", "a0", "a1" );})

#define __FPuts(__dos, ___fh, ___str) ({\
  register void * __p_dos __asm("a6") = (void *)(__dos);\
  register LONG __p_fh __asm("d1") = (LONG)(___fh);\
  register const char * __p_str __asm("d2") = (const char *)(___str);\
  __asm volatile ("jsr %/a6@(-342:W)\n"\
		   : : "d"(__p_fh), "d"(__p_str), "a"(__p_dos)\
		   : "cc", "memory", "d0", "a0", "a1" );})

#define __Flush(__dos, ___fh) ({\
  register void * __p_dos __asm("a6") = (void *)(__dos);\
  register LONG __p_fh __asm("d1") = (LONG)(___fh);\
  __asm volatile ("jsr %/a6@(-360:W)\n"\
		   : : "d"(__p_fh), "a"(__p_dos)\
		   : "cc", "memory", "d0", "a0", "a1" );})

#define SYSBASE	(*(struct ExecBase **)4)

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

struct Library *LibInit(struct AFBase *base __asm("d0"),
			BPTR seglist __asm("a0"),
			struct ExecBase *sys __asm("a6"))
{
    base->af_Sys = sys;
    base->af_SegList = seglist;
    base->af_Dos = (struct Library *)__OpenLibrary(sys, s_doslib, 0);

    return (struct Library *)base;
}

struct Library *LibOpen(struct AFBase *base __asm("a6"),
			LONG version __asm("d0"))
{
    /* original quirk: skips the open when the version arg is
    ** < 1, returning the (<=0) argument itself */
    if (version >= 1) {
	base->af_Lib.lib_OpenCnt++;
	base->af_Lib.lib_Flags &= ~LIBF_DELEXP;
	return (struct Library *)base;
    }
    return (struct Library *)version;
}

BPTR LibExpunge(struct AFBase *base __asm("a6"));

LONG LibClose(struct AFBase *base __asm("a6"))
{
    LONG res = 0;

    if (!--base->af_Lib.lib_OpenCnt &&
	(base->af_Lib.lib_Flags & LIBF_DELEXP))
	res = (LONG)LibExpunge(base);

    return res;
}

BPTR LibExpunge(struct AFBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->af_Lib.lib_OpenCnt) {
	base->af_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = base->af_SegList;
    __Remove(sys, &base->af_Lib.lib_Node);
    __CloseLibrary(sys, base->af_Dos);
    __FreeMem(sys, (UBYTE *)base - base->af_Lib.lib_NegSize,
	      (ULONG)base->af_Lib.lib_NegSize + base->af_Lib.lib_PosSize);

    return seg;
}

/* -24 reserved: returns 0 */
LONG LibNull(void)
{
    return 0;
}

/* ------------------------------------------------------------------ */
/* output vectors							  */
/* ------------------------------------------------------------------ */

/* -72 AFPutChar: FPutC(handle, ch) + Flush -- flushes every char */
void AFPutChar(ULONG ch __asm("d0"), void *handle __asm("a1"),
	       struct AFBase *base __asm("a6"))
{
    __FPutC(base->af_Dos, (LONG)handle, ch & 0xff);
    __Flush(base->af_Dos, (LONG)handle);
}

/* -36 AFNewLine: emits LF then CR (reversed from convention) */
void AFNewLine(void *handle __asm("a1"), struct AFBase *base __asm("a6"))
{
    AFPutChar(10, handle, base);
    AFPutChar(13, handle, base);
}

/* -78 AFPutNibble */
void AFPutNibble(ULONG n __asm("d0"), void *handle __asm("a1"),
		 struct AFBase *base __asm("a6"))
{
    ULONG c = (n & 0xf) + '0';
    if (c > '9')
	c += 7;
    AFPutChar(c, handle, base);
}

/* -84 AFPutByte */
void AFPutByte(ULONG b __asm("d0"), void *handle __asm("a1"),
	       struct AFBase *base __asm("a6"))
{
    AFPutNibble(b >> 4, handle, base);
    AFPutNibble(b, handle, base);
}

/* -90 AFPutWord */
void AFPutWord(ULONG w __asm("d0"), void *handle __asm("a1"),
	       struct AFBase *base __asm("a6"))
{
    AFPutByte(w >> 8, handle, base);
    AFPutByte(w, handle, base);
}

/* -96 AFPutLong */
void AFPutLong(ULONG l __asm("d0"), void *handle __asm("a1"),
	       struct AFBase *base __asm("a6"))
{
    AFPutWord(l >> 16, handle, base);
    AFPutWord(l, handle, base);
}

/* -102 AFPutString: FPuts(handle, str) + Flush; str in d2 */
void AFPutString(const char *str __asm("d2"), void *handle __asm("a1"),
		 struct AFBase *base __asm("a6"))
{
    __FPuts(base->af_Dos, (LONG)handle, str);
    __Flush(base->af_Dos, (LONG)handle);
}

/* -108 AFPutSpace */
void AFPutSpace(void *handle __asm("a1"), struct AFBase *base __asm("a6"))
{
    AFPutChar(' ', handle, base);
}

/* -114 AFPutSpaces */
void AFPutSpaces(ULONG n __asm("d0"), void *handle __asm("a1"),
		 struct AFBase *base __asm("a6"))
{
    while (n--)
	AFPutSpace(handle, base);
}

/* -60 AFCharAvail: WaitForChar(handle, 1) */
LONG AFCharAvail(void *handle __asm("a1"), struct AFBase *base __asm("a6"))
{
    return __WaitForChar(base->af_Dos, (LONG)handle, 1);
}

/* ------------------------------------------------------------------ */
/* prompt vector							  */
/* ------------------------------------------------------------------ */

/*
**	-42 AFEnterAddress
**
**	Prompts "  Enter Address : ", reads hex digits until a
**	non-hex char; anything but CR -> bell + newline + reprompt.
**	A CR-terminated value that is ODD -> "*** INVALID ADDRESS
**	***" + bell + newline + reprompt (the parity bit doubles
**	as an alignment check).  Returns the address in a0, like
**	the original (d0/d1 restored by the wrapper).
*/
void *AFEnterAddress(void *handle __asm("a1"), struct AFBase *base __asm("a6"))
{
    ULONG value;

    for (;;) {
	AFPutString(s_prompt, handle, base);
	ULONG term = (ULONG)AFReadHex(handle, base);
	__asm volatile("movel %%d1,%0" : "=r"(value));
	if (term != 13) {
	    AFPutChar(7, handle, base);		/* bell */
	    AFNewLine(handle, base);
	    continue;
	}
	if (value & 1) {
	    AFPutString(s_badaddr, handle, base);
	    AFPutChar(7, handle, base);
	    AFNewLine(handle, base);
	    continue;
	}
	break;
    }

    {
	register void *res __asm("a0") = (void *)value;
	__asm volatile("" : "+r"(res));
	return res;
    }
}
