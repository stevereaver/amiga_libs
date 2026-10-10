/*
**	mathieeesingbas.c -- framework functions for
**	mathieeesingbas.library "MSB 10.881"
**	(Kickstart 1.x disk library for the MC68881/68882).
**
**	Implements the AUTOINIT init routine plus Open/Close/
**	Expunge and the reserved vector.  All IEEE primitives
**	live in math.s (verbatim 68881 sequences).
**
**	Shipped-binary semantics:
**	- LibInit runs with a6 = ExecBase, d0 = new base,
**	  a0 = seglist.  Without AFF_68881 it frees the freshly
**	  allocated base (NegSize+PosSize) and fails the
**	  resident init.  With an FPU it stashes the seglist in
**	  a longword cell inside the code hunk (text+0x2c).
**	- LibOpen forces FPCR to 0x80 unless it is already a
**	  plausible nonzero mode (see note in okf/findings).
**	- Expunge unlinks the node, frees vectors+base via
**	  FreeMem (ExecBase taken from absolute address 4) and
**	  returns the stashed seglist.
*/

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/execbase.h>

/* seglist cell inside the code hunk (emitted by mathieeesingbas_lib.s) */
extern ULONG segcell[1];

/* exec.library thunk (math.s): FreeMem(a1, d0) with a6 = ExecBase */
extern void XFreeMem(APTR mem __asm("a1"), ULONG size __asm("d0"), APTR eb __asm("a6"));

/* ----------------------------------------------------------------
 * LibInit -- AUTOINIT init routine.
 *   d0 = new library base (or 0), a0 = seglist, a6 = ExecBase.
 *   Returns the base on success, 0 to abort the resident init.
 * ---------------------------------------------------------------- */
ULONG LibInit(ULONG base __asm("d0"), APTR seg __asm("a0"), struct ExecBase *eb __asm("a6"))
{
    struct Library *lib = (struct Library *)base;

    if (!lib)
        return 0;

    if (!(eb->AttnFlags & AFF_68881)) {
        /* no coprocessor: free the allocated base and fail */
        APTR mem = (UBYTE *)lib - lib->lib_NegSize;
        XFreeMem(mem, (ULONG)lib->lib_NegSize + lib->lib_PosSize, eb);
        return segcell[0];             /* still zero -> init fails */
    }

    segcell[0] = (ULONG)seg;           /* stashed for expunge */
    return base;
}

/* ----------------------------------------------------------------
 * LibOpen -- a6 = lib base.
 *   Original code reads FPCR, and writes 0x80 unless FPCR is
 *   already nonzero-and-not-single-precision (the shipped beq
 *   actually tests the caller's CCR -- FMOVE.L FPCR,Dn does not
 *   set condition codes; reconstructed as the intended fpcr==0).
 *   Then OpenCnt++, clears LIBF_DELEXP, returns the base.
 * ---------------------------------------------------------------- */
struct Library *LibOpen(struct Library *lib __asm("a6"))
{
    ULONG fpcr;
    __asm volatile ("fmovel %%fpcr,%0" : "=d"(fpcr));
    if ((UWORD)fpcr == 0 || ((UWORD)fpcr >= 0x40 && (UWORD)fpcr < 0x80))
        __asm volatile ("fmovel %0,%%fpcr" :: "di"(0x80));

    lib->lib_OpenCnt++;
    lib->lib_Flags &= ~LIBF_DELEXP;
    return lib;
}

static __inline__ __attribute__((always_inline))
ULONG DoExpunge(struct Library *lib __asm("a6"))
{
    struct Node *n  = &lib->lib_Node;
    UBYTE *mem      = (UBYTE *)lib - lib->lib_NegSize;
    ULONG  size     = (ULONG)lib->lib_NegSize + lib->lib_PosSize;

    n->ln_Pred->ln_Succ = n->ln_Succ;         /* unlink node */
    n->ln_Succ->ln_Pred = n->ln_Pred;

    XFreeMem(mem, size, *(APTR *)4L);         /* ExecBase via 4.w */
    return segcell[0];                       /* return seglist */
}

/* ----------------------------------------------------------------
 * LibClose -- a6 = lib base.
 *   OpenCnt--; on zero with LIBF_DELEXP set, expunges.
 * ---------------------------------------------------------------- */
ULONG LibClose(struct Library *lib __asm("a6"))
{
    if (--lib->lib_OpenCnt == 0 && (lib->lib_Flags & LIBF_DELEXP))
        return DoExpunge(lib);
    return 0;
}

/* ----------------------------------------------------------------
 * LibExpunge -- a6 = lib base.
 *   Busy -> mark LIBF_DELEXP and return 0; idle -> remove+free,
 *   return seglist.
 * ---------------------------------------------------------------- */
ULONG LibExpunge(struct Library *lib __asm("a6"))
{
    if (lib->lib_OpenCnt) {
        lib->lib_Flags |= LIBF_DELEXP;
        return 0;
    }
    return DoExpunge(lib);
}

/* reserved LVO -24 */
ULONG LibNull(void)
{
    return 0;
}
