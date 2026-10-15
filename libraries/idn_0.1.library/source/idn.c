/*
 * idn.library 0.1 (Marz 2004) - IDNA/punycode support library.
 *
 * C model for the shipped vectors (the byte-identical build is
 * h0.s; this file documents the semantics in C form).
 *
 * Vectors:  -30 IDN_Normalize   nameprep-style fold (tolower,
 *                               sharp-s -> "ss", strip soft hyphen)
 *           -36 IDN_Encode      punycode encode (+name check)
 *           -42 IDN_Decode      punycode decode
 *           -48 IDN_Free        FreeMem() a returned string
 *
 * Function names are reconstructed - the binary ships no fd.
 */
#include <exec/types.h>
#include <exec/memory.h>
#include <proto/exec.h>

/* -30: LIBFUNC_0 - in-place-ish fold a0 -> a1.
 * Lowercases A-Z (bset #5), maps 0xdf -> "ss", drops 0xad,
 * copies everything else verbatim (incl. high bytes). */
void IDN_Normalize(UBYTE *src __asm("a0"), UBYTE *dst __asm("a1"))
{
    UBYTE c;
    while ((c = *src++)) {
        if (c & 0x80) {
            if (c == 0xdf) { *dst++ = 's'; *dst++ = 's'; continue; }
            if (c == 0xad) continue;
        } else if (c >= 'A' && c <= 'Z')
            c |= 0x20;
        *dst++ = c;
    }
    *dst = 0;   /* shipped loop exits on NUL without writing it -
                   callers rely on pre-cleared/short dst; the C model
                   terminates explicitly (documented delta). */
}

/* ---- punycode constants observed in the binary: base 36,
        tmin-ish path uses 0x1a (26), bias math uses 36/26/2 ---- */
#define PC_BASE   36
#define PC_TMIN    1
#define PC_TMAX   26
#define PC_SKEW   38
#define PC_DAMP  700
#define PC_BIAS   72
#define PC_INIT_N 128
#define PC_DELIM  '-'

static LONG pc_digit(LONG c)          { return c < 26 ? c + 'a' : c - 26 + '0'; }
static LONG pc_val(LONG c)
{
    if (c >= '0' && c <= '9') return c - '0' + 26;
    if (c >= 'a' && c <= 'z') return c - 'a';
    if (c >= 'A' && c <= 'Z') return c - 'a';
    return -1;
}
static LONG pc_adapt(LONG delta, LONG numpoints, LONG first)
{
    LONG k;
    delta = first ? delta / PC_DAMP : delta / 2;
    delta += delta / numpoints;
    for (k = 0; delta > ((PC_BASE - PC_TMIN) * PC_TMAX) / 2; k += PC_BASE)
        delta /= PC_BASE - PC_TMIN;
    return k + (((PC_BASE - PC_TMIN + 1) * delta) / (delta + PC_SKEW));
}

/* -36: encode Unicode label (0x80-0xFF high bytes -> punycode).
 * Returns an AllocMem'd C string (or NULL).  Ship behavior: calls
 * a regexp.library name check first, then the encoder core. */
STRPTR IDN_Encode(UBYTE *in __asm("a0"))
{
    /* faithful-structure port of LAB_0064 path:
       validate with regexp (LAB_0003), then encode. */
    extern LONG IDN_CheckName(UBYTE *);   /* internal, h0.s */
    if (!IDN_CheckName(in))
        return NULL;
    /* ... encoder core omitted in model - see h0.s / okf notes */
    return NULL;
}

/* -42: decode punycode label back to 8-bit. */
STRPTR IDN_Decode(UBYTE *in __asm("a0"))
{
    extern LONG IDN_CheckName(UBYTE *);
    if (!IDN_CheckName(in))
        return NULL;
    return NULL;
}

/* -48: LIBFUNC_3 - FreeMem(strlen(a0)+1, a0).  Exact. */
LONG IDN_Free(UBYTE *p __asm("a0"))
{
    ULONG n = 0;
    if (!p)
        return 0;
    while (p[n]) n++;
    __FreeMem_base(*(void **)4, p, n + 1);
    return 0;
}
