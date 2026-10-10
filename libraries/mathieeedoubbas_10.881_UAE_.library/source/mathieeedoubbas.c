/*
**	mathieeedoubbas.c -- framework functions for
**	mathieeedoubbas.library "MDB 10.881"
**	(Kickstart 1.x disk library for the MC68881/68882).
**
**	Implements the AUTOINIT init routine plus Open/Close/
**	Expunge and the reserved vector.  All IEEE primitives
**	live in math.s (verbatim 68881 sequences).
**
**	Shipped-binary semantics:
**	- LibInit runs with a6 = ExecBase, d0 = new base,
**	  a0 = seglist.  Without AFF_68881 it opens and closes
**	  "Libs:NoFPU/mathieeedoubbas.library" v36 (the software
**	  fallback), then frees the returned base's memory via
**	  the shared NegSize/PosSize free routine, and fails the
**	  resident init (see okf/findings -- this path is odd).
**	  With an FPU it stashes the seglist in a longword cell
**	  inside the code hunk (text+0x2c).
**	- LibOpen unconditionally writes FPCR = 0x10.
**	- Expunge unlinks the node, frees vectors+base via
**	  FreeMem (ExecBase taken from absolute address 4) and
**	  returns the stashed seglist.
*/

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/execbase.h>

/* seglist cell inside the code hunk (emitted by mathieeedoubbas_lib.s) */
extern ULONG segcell[1];

/* "Libs:NoFPU/..." string (tail is the library name) -- datatab.s */
extern const char nofpuname[];

/* exec.library thunks (math.s), a6 = ExecBase */
extern void XFreeMem(APTR mem __asm("a1"), ULONG size __asm("d0"), APTR eb __asm("a6"));
extern struct Library *XOpenLibrary(const char *name __asm("a1"), ULONG version __asm("d0"), APTR eb __asm("a6"));
extern void XCloseLibrary(struct Library *lib __asm("a1"), APTR eb __asm("a6"));

/* shared remove+free tail (also used by the init-failure path) */
static __inline__ __attribute__((always_inline))
ULONG FreeTail(struct Library *base __asm("a1"))
{
    UBYTE *mem  = (UBYTE *)base - base->lib_NegSize;
    ULONG  size = (ULONG)base->lib_NegSize + base->lib_PosSize;

    XFreeMem(mem, size, *(APTR *)4L);           /* ExecBase via 4.w */
    return segcell[0];                          /* seglist / 0 */
}

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
        /*
         * No coprocessor: as shipped -- open + immediately close the
         * Libs:NoFPU/ fallback library, then run the free tail on the
         * base OpenLibrary returned.  (The original pushed the new
         * base and popped it into d1, unused -- dead restore.)
         */
        struct Library *nofpu = XOpenLibrary(nofpuname, 36, eb);
        XCloseLibrary(nofpu, eb);
        return FreeTail(nofpu);
    }

    segcell[0] = (ULONG)seg;            /* stashed for expunge */
    return base;
}

/* ----------------------------------------------------------------
 * LibOpen -- a6 = lib base.  Writes FPCR = 0x10 (extended
 * precision, round-toward-zero), then OpenCnt++, clears
 * LIBF_DELEXP, returns the base.
 * ---------------------------------------------------------------- */
struct Library *LibOpen(struct Library *lib __asm("a6"))
{
    __asm volatile ("fmovel %0,%%fpcr" :: "di"(0x10));

    lib->lib_OpenCnt++;
    lib->lib_Flags &= ~LIBF_DELEXP;
    return lib;
}

/* ----------------------------------------------------------------
 * LibClose -- a6 = lib base.
 *   OpenCnt--; on zero with LIBF_DELEXP set, expunges.
 * ---------------------------------------------------------------- */
ULONG LibClose(struct Library *lib __asm("a6"))
{
    if (--lib->lib_OpenCnt == 0 && (lib->lib_Flags & LIBF_DELEXP)) {
        struct Node *n = &lib->lib_Node;
        n->ln_Pred->ln_Succ = n->ln_Succ;
        n->ln_Succ->ln_Pred = n->ln_Pred;
        return FreeTail(lib);
    }
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
    {
        struct Node *n = &lib->lib_Node;
        n->ln_Pred->ln_Succ = n->ln_Succ;
        n->ln_Succ->ln_Pred = n->ln_Pred;
        return FreeTail(lib);
    }
}

/* reserved LVO -24 */
ULONG LibNull(void)
{
    return 0;
}
