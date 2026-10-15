/*
 * xpkRLEN.library 1.1 - "Run Length" XPK sublibrary (Nov 1992)
 *
 * PackBits-style chunk packer, reconstructed from the shipped
 * binary's LIBFUNC_1 (pack) / LIBFUNC_4 (unpack).
 *
 * Stream format:
 *   code > 0 : copy <code> literal bytes
 *   code < 0 : repeat next byte <-code> times
 *   code = 0 : end of stream
 * Runs are detected on >=3 equal bytes; literal runs cap at 127.
 * Pack returns XPKERR_EXPANSION (-17) if the output would overflow.
 */
#include "xpkbase.h"

/* LVO -30: descriptor block lives in the copied template area. */
APTR XpksPackerInfo(struct XpkSubBase *base __asm("a6"))
{
    return (UBYTE *)base + XPKINFO_OFF;
}

/* LVO -36: PackBits encoder (faithful port of the shipped loop). */
LONG XpksPackChunk(struct XpkSubParams *p __asm("a0"),
                   struct XpkSubBase *base __asm("a6"))
{
    UBYTE *src    = (UBYTE *)p->xsp_InBuf;
    UBYTE *srcend = src + p->xsp_InLen;
    UBYTE *out    = (UBYTE *)p->xsp_OutBuf;
    UBYTE *outlim = out + p->xsp_OutBufLen;
    UBYTE *lit    = src;          /* literal run start (a2) */
    LONG   pend, run;

    for (;;) {
        /* run ahead?  a0[0]==a0[1]==a0[2] -> repeat run pending */
        run = (src[0] == src[1] && src[1] == src[2]);
        pend = src - lit;                       /* pending literals */

        if (out + pend + 4 > outlim)            /* token won't fit */
            return -17;                         /* XPKERR_EXPANSION */

        if (run || pend == 127 || src == srcend) {
            /* flush the literal run, if any */
            if (pend) {
                LONG n = pend;
                *out++ = (UBYTE)pend;
                while (n-- > 0)
                    *out++ = *lit++;
            }
            if (src == srcend)
                break;                          /* -> terminator  */
            lit = src;
            if (!run) {                         /* extend literal */
                src++;
                continue;
            }
            /* measure run: min 3, cap 127 */
            run = 3;
            while (src + run < srcend
                   && src[run] == src[run - 1]
                   && run < 127)
                run++;
            lit += run;
            *out++ = (UBYTE)(-(BYTE)run);       /* -count         */
            *out++ = src[0];                    /*   + value      */
            src = lit;
        } else {
            src++;                              /* grow literal   */
        }
    }

    *out++ = 0;
    p->xsp_OutLen = out - (UBYTE *)p->xsp_OutBuf;
    return 0;
}

/* LVO -54: decoder.  >0 literal copy, <0 repeat, 0 ends. */
LONG XpksUnpackChunk(struct XpkSubParams *p __asm("a0"),
                     struct XpkSubBase *base __asm("a6"))
{
    UBYTE *in  = (UBYTE *)p->xsp_InBuf;
    UBYTE *out = (UBYTE *)p->xsp_OutBuf;
    BYTE   code;

    for (;;) {
        code = (BYTE)*in++;
        if (code == 0)
            break;
        if (code < 0) {
            UBYTE v = *in++;
            WORD  n = -code;   /* negated as a long: 0x80 -> 128 */
            while (n-- > 0)
                *out++ = v;
        } else {
            WORD n = code;
            while (n-- > 0)
                *out++ = *in++;
        }
    }
    return 0;
}
