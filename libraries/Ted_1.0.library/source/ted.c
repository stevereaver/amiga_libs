/*
 * ted.c -- ted.library 1.0 (28.12.95)
 *
 * Shared-variable / method-dispatch shim.  Sixteen trivial vectors:
 * five setters write client pointers into code-hunk globals g1..g5,
 * simple getters dereference them, and global 3 anchors an external
 * structure whose +12/+100 offsets are called as methods and +104/
 * +108/+112/+116 read as string/pointer fields.
 *
 * The globals and the scratch buffer live in ted_lib.s so they stay
 * absolute-addressed inside the single code hunk like the original.
 */

typedef unsigned long  ULONG;
typedef unsigned short UWORD;
typedef char          *STRPTR;
typedef void          *APTR;

typedef unsigned char  UBYTE;
extern APTR g1, g2, g3, g4, g5;
extern UBYTE buf[];                 /* ~255-byte scratch buffer   */

/* -30/-36/-54/-72/-78: store client pointer in a global            */
void ted_setg1(void) { register APTR a0 __asm("a0"); g1 = a0; }
void ted_setg2(void) { register APTR a0 __asm("a0"); g2 = a0; }
void ted_setg3(void) { register APTR a0 __asm("a0"); g3 = a0; }
void ted_setg4(void) { register APTR a0 __asm("a0"); g4 = a0; }
void ted_setg5(void) { register APTR a0 __asm("a0"); g5 = a0; }

/* -42: d0 = *g1 (longword)                                         */
ULONG ted_getg1(void) { return *(ULONG *)g1; }

/* -48: d0 = *g2 (uword, zero-extended)                             */
ULONG ted_getg2w(void) { return *(UWORD *)g2; }

/* -60: d0 = g3 (the pointer itself)                                */
ULONG ted_getg3(void) { return (ULONG)g3; }

/* -66: tail-call the function pointer at g3+12                     */
void ted_callg3m12(void)
{
    register APTR slot __asm("a1") = *(APTR **)((UBYTE *)g3 + 12);
    __asm volatile("jmp a1@\n" :: "r"(slot) : "memory");
    __builtin_unreachable();
}

/* -84/-90: d0 = *g4 / *g5 (longword)                               */
ULONG ted_getg4(void) { return *(ULONG *)g4; }
ULONG ted_getg5(void) { return *(ULONG *)g5; }

/* -96: call *(g3+100) with a1 = scratch buffer; returns &buffer.
 * The original defensively saves d2-d7/a2-a5 around the jsr.        */
STRPTR ted_callg3m100(void)
{
    register STRPTR __a1 __asm("a1") = (STRPTR)buf;
    register APTR   __a2 __asm("a2") = *(APTR *)((UBYTE *)g3 + 100);
    __asm volatile("moveml d2-d7/a2-a5,sp@-\n\t"
                   "jsr a2@\n\t"
                   "moveml sp@+,d2-d7/a2-a5\n"
        : "+r"(__a1) : "r"(__a2) : "d0","a0","cc","memory");
    return (STRPTR)buf;
}

/* -102/-108: strcpy(*(g3+104/+108)) into the buffer, return it     */
static STRPTR bufcpy(ULONG off)
{
    STRPTR s = **(STRPTR **)((UBYTE *)g3 + off);
    STRPTR d = (STRPTR)buf;
    while ((*d++ = *s++) != 0) ;
    return (STRPTR)buf;
}
STRPTR ted_strg3p104(void) { return bufcpy(104); }
STRPTR ted_strg3p108(void) { return bufcpy(108); }

/* -114/-120: d0 = longword at (*(g3+112/+116)) - 2                 */
static ULONG ptrm2(ULONG off)
{
    UBYTE *p = *(UBYTE **)((UBYTE *)g3 + off);
    return *(ULONG *)(p - 2);
}
ULONG ted_getg3p112m2(void) { return ptrm2(112); }
ULONG ted_getg3p116m2(void) { return ptrm2(116); }
