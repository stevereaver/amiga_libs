/*
**	ksort.c -- C reconstruction of ksort.library 34.1
**	"ksort.library 34.1 (01 Jan 93)".
**
**	A tiny SAS/C-era utility library exporting seven recursive
**	quicksort variants (the RareOldLibs readme calls them
**	"customized Quicksort algorithms").  No public headers
**	survive, so the entry names below are descriptive.
**
**	Vector map (AUTOINIT, ABSOLUTE-LONG functab, 11 vectors):
**
**	  -6  LibOpen         -30 KSortI8  (signed   bytes)
**	  -12 LibClose        -36 KSortU8  (unsigned bytes)
**	  -18 LibExpunge      -42 KSortI16 (signed   words)
**	  -24 null stub       -48 KSortU16 (unsigned words)
**	                      -54 KSortI32 (signed   longs)
**	                      -60 KSortU32 (unsigned longs)
**	                      -66 KSortStr (char * array, case
**	                          insensitive via built-in stricmp)
**
**	Calling convention: every sort takes (array:d0, count:d1)
**	and sorts array[0..count-1] in place.  The d0 result is
**	unspecified compare residue in the original.
**
**	Worker structure (all variants):
**
**	  pivot = a[(lo+hi)/2]                computed before the
**	  while (i <= j) {                    empty-range test
**	      while (a[i] <  pivot) i++;      unbounded scans --
**	      while (a[j] >  pivot) j--;      safe only because the
**	      if (i <= j) { swap; i++; j--; } pivot is an element
**	  }
**	  if (lo < j) qs(a, lo, j);
**	  if (i < hi) qs(a, i, hi);
**
**	The string variant differs: the inner scans carry an extra
**	i < j bound and compare through stricmp(a[x], pivot) with
**	pivot being an element pointer, not an index.
**
**	For count <= 0 the partition loop is skipped, but the pivot
**	is still read at a[(0+count-1)/2] -- a[0] for count == 0,
**	a negative index for negative counts (a wild read either
**	way; reproduced faithfully).
**
**	Shipped quirks reproduced:
**	  - the pivot index is (lo+hi)/2 with C truncation-toward-
**	    zero semantics (the original emits the classic
**	    tst/addq/asr sequence), so negative ranges pivot on a
**	    negative index.
**	  - LibInit opens dos/intuition/graphics and stashes their
**	    bases in a static block, but no entry point ever reads
**	    them -- vestigial framework boilerplate.
**	  - LibExpunge tests lib_OpenCnt through the CALLER's a5
**	    (tst.w 0x20(a5), a5 never loaded) -- a wild read; then
**	    calls CloseLibrary on the three NAME STRINGS (a1 =
**	    "dos.library" etc., not the opened bases); then stores
**	    the seglist to ABSOLUTE ADDRESS 0 (a missing relocation
**	    in the shipped binary, intended target likely the
**	    SysBase global) and returns CloseLibrary's residual d0
**	    instead of the seglist.  See okf/findings/defects.md.
*/

#ifndef HOST_TEST

#include <exec/types.h>
#include <exec/libraries.h>

#define REGPARM_D0 __asm("d0")
#define REGPARM_D1 __asm("d1")
#define REGPARM_A6 __asm("a6")

#else /* HOST_TEST */

#include <stdint.h>
typedef uint8_t		UBYTE;
typedef int8_t		BYTE;
typedef uint16_t	UWORD;
typedef int16_t		WORD;
typedef uint32_t	ULONG;
typedef int32_t		LONG;
typedef void *		APTR;

#define REGPARM_D0
#define REGPARM_D1
#define REGPARM_A6

#endif /* HOST_TEST */

/* ------------------------------------------------------------ */
/* stricmp -- the hunk-3 comparator.  Both arguments arrive on   */
/* the stack in the original; returns (toupper(c1)-toupper(c2)). */
/* ------------------------------------------------------------ */

static LONG kstricmp(const UBYTE *s1, const UBYTE *s2)
{
    LONG c1, c2;

    do {
	c1 = *s1++;
	c2 = *s2++;
	if (c1 >= 'a' && c1 <= 'z') c1 -= 32;
	if (c2 >= 'a' && c2 <= 'z') c2 -= 32;
	c1 -= c2;
    } while (c1 == 0 && c2 != 0);
    return c1;
}

/* ------------------------------------------------------------ */
/* The recursive worker, expanded per element type/compare.      */
/* The original keeps the pivot in a stack slot, i in d6,        */
/* j in d5, base in a2 and (for word/long/string variants) a     */
/* descending element cursor in a frame slot; behaviour is the   */
/* textbook partition + two recursive calls.                     */
/* ------------------------------------------------------------ */

#define KSORT_QS(name, type)						\
static void name(type *a, LONG lo, LONG hi)				\
{									\
    LONG i = lo, j = hi;						\
    type pivot = a[(lo + hi) / 2];					\
    while (i <= j) {							\
	while (a[i] < pivot)  i++;					\
	while (a[j] > pivot)  j--;					\
	if (i <= j) {							\
	    type t = a[i];						\
	    a[i] = a[j]; a[j] = t;					\
	    i++; j--;							\
	}								\
    }									\
    if (lo < j) name(a, lo, j);						\
    if (i < hi) name(a, i, hi);						\
}

KSORT_QS(qs_i8,  BYTE)
KSORT_QS(qs_u8,  UBYTE)
KSORT_QS(qs_i16, WORD)
KSORT_QS(qs_u16, UWORD)
KSORT_QS(qs_i32, LONG)

/* qs_u32 is UNIQUE: the original's index comparisons are all
 * UNSIGNED (bls/bhi/bcc instead of ble/bgt/bge) -- the compiler
 * treated i/j/lo/hi as ULONG, probably because the element type
 * is unsigned.  When a partition at index 0 self-swaps
 * (i == j == 0 -> i = 1, j = -1) the unsigned i <= j test stays
 * true and the j cursor walks below the array, swapping garbage
 * into the array and array values into wild memory.  Reproduced
 * verbatim: qs(a,0,1) triggers it on every call.		    */
static void qs_u32(ULONG *a, LONG lo, LONG hi)
{
    ULONG i = (ULONG)lo, j = (ULONG)hi;
    ULONG pivot = a[(lo + hi) / 2];	/* signed mid: (0,-1)/2 = 0 */

    while (i <= j) {				/* unsigned	    */
	while (a[i] < pivot) i++;
	while (a[j] > pivot) j--;
	if (i <= j) {
	    ULONG t = a[i];
	    a[i] = a[j]; a[j] = t;
	    i++; j--;
	}
    }
    if (j > (ULONG)lo) qs_u32(a, lo, (LONG)j);	/* blss: skip j U<=lo */
    if (i < (ULONG)hi) qs_u32(a, (LONG)i, hi);	/* bccs: skip i U>=hi */
}

static void qs_str(UBYTE **a, LONG lo, LONG hi)
{
    LONG i = lo, j = hi;
    UBYTE *pivot = a[(lo + hi) / 2];

    while (i <= j) {
	while (kstricmp(a[i], pivot) < 0 && i < j) i++;
	while (kstricmp(a[j], pivot) > 0 && i < j) j--;
	if (i <= j) {
	    UBYTE *t = a[i];
	    a[i] = a[j]; a[j] = t;
	    i++; j--;
	}
    }
    if (lo < j) qs_str(a, lo, j);
    if (i < hi) qs_str(a, i, hi);
}

/* ------------------------------------------------------------ */
/* Public entry points.  The original wraps each worker in an   */
/* identical prologue (save d2/a2/d7, call worker(a,0,count-1)). */
/* ------------------------------------------------------------ */

void KSortI8(BYTE *a REGPARM_D0, LONG n REGPARM_D1, APTR lib REGPARM_A6)
{
    qs_i8(a, 0, n - 1);
}

void KSortU8(UBYTE *a REGPARM_D0, LONG n REGPARM_D1, APTR lib REGPARM_A6)
{
    qs_u8(a, 0, n - 1);
}

void KSortI16(WORD *a REGPARM_D0, LONG n REGPARM_D1, APTR lib REGPARM_A6)
{
    qs_i16(a, 0, n - 1);
}

void KSortU16(UWORD *a REGPARM_D0, LONG n REGPARM_D1, APTR lib REGPARM_A6)
{
    qs_u16(a, 0, n - 1);
}

void KSortI32(LONG *a REGPARM_D0, LONG n REGPARM_D1, APTR lib REGPARM_A6)
{
    qs_i32(a, 0, n - 1);
}

void KSortU32(ULONG *a REGPARM_D0, LONG n REGPARM_D1, APTR lib REGPARM_A6)
{
    qs_u32(a, 0, n - 1);
}

void KSortStr(UBYTE **a REGPARM_D0, LONG n REGPARM_D1, APTR lib REGPARM_A6)
{
    qs_str(a, 0, n - 1);
}
