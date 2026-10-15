/*
 * mathffp.library 36.5 reconstruction
 *
 * FFP: [31:8]=24-bit normalized mantissa, [7]=sign, [6:0]=exp biased 64.
 * Register ABI: unary ops take d0; binary ops take (left=d1, right=d0)
 * and compute "right OP left" (d0 op d1): SPSub → d0-d1, SPDiv → d0/d1.
 * SPCmp/SPTst snapshot condition codes via exec GetCC(-528) and return
 * them restored in the CCR.
 */

#include <exec/types.h>
#include <exec/libraries.h>

typedef ULONG  U32;
typedef LONG   S32;
typedef UWORD  U16;
typedef signed char S8;

struct Lib {
    U32 *succ;           /* @0  ln_Succ */
    U32 *pred;           /* @4  ln_Pred */
    UBYTE  pad8[6];         /* @8  ln_Type/ln_Pri/ln_Name */
    UBYTE  flags;           /* @14 lib_Flags (LIBF_DELEXP=8) */
    UBYTE  pad15;
    U16 negsize;         /* @16 */
    U16 possize;         /* @18 */
    UBYTE  pad20[12];
    U16 opencnt;         /* @32 */
};

#define REG(r) register __asm(r)
#define SETV()     __asm volatile("ori.b #2,%ccr")
#define SETCCR(cc) __asm volatile("move.w %0,%%ccr" :: "d"((U16)(cc)))

static __inline__ int sb8(U32 b) { return (int)(S8)(b & 0xff); }
static __inline__ U32 swp(U32 x) { return (x << 16) | (x >> 16); }

/* 68k-style subtract flags for a-b: returns CCR byte (X N Z V C) */
static __inline__ U32 cc_sub(U32 a, U32 b, int isbyte)
{
    U32 mask = isbyte ? 0xff : 0xffffffff;
    U32 sgn  = isbyte ? 0x80 : 0x80000000;
    U32 aa = a & mask, bb = b & mask, r = (aa - bb) & mask;
    U32 n = (r & sgn) ? 8 : 0, z = (r == 0) ? 4 : 0;
    U32 v = ((aa ^ bb) & (aa ^ r) & sgn) ? 2 : 0;
    U32 c = (aa < bb) ? 1 : 0;
    return n | z | v | c | (c << 4);
}

/* ---------------- conversion --------------------------------------------- */

LONG SPFix(S32 f __asm("d0"))
{
    U32 d0 = (U32)f, d1 = d0 & 0xff;
    if (d1 & 0x80) {                        /* negative */
        d0 &= 0xffffff00;
        d1 = (d1 - 0xc1) & 0xff;
        if (d1 & 0x80) return 0;            /* |x| < 1 */
        d1 = (d1 - 0x1f) & 0xff;
        if (!(d1 & 0x80)) {                 /* s >= 31 */
            if (d1 != 0) { SETV(); return (S32)0x80000000; }
            d0 = (U32)0 - d0;
            if ((S32)d0 < 0) return (S32)d0;/* exactly -2^31 */
            SETV(); return (S32)0x80000000;
        }
        d1 = (-d1) & 0xff;
        return (S32)(0u - (d0 >> d1));
    }
    if (d1 == 0) return (S32)d0;            /* byte 0 → returned unmasked */
    d0 &= 0xffffff00;
    d1 = (d1 - 0x41) & 0xff;
    if (d1 & 0x80) return 0;
    d1 = (d1 - 0x1f) & 0xff;
    if (!(d1 & 0x80)) { SETV(); return 0x7fffffff; }
    d1 = (-d1) & 0xff;
    return (S32)(d0 >> d1);
}

LONG SPFlt(S32 v __asm("d0"))
{
    U32 d0 = (U32)v, d1 = 0x5f;
    if (d0 == 0) return 0;
    if ((S32)d0 < 0) {
        d1 = 0xffffffe0;                    /* moveq #-32 → byte 0xe0 */
        d0 = (U32)0 - d0;
        if (d0 == 0x80000000)               /* -2^31: neg.l V → merge as-is */
            return (S32)((d0 & 0xffffff00) | (d1 & 0xff));
        d1 = (d1 - 1) & 0xff;               /* 0xdf */
    }
    if (d0 <= 0x7fff) { d0 = swp(d0); d1 = (d1 - 16) & 0xff; }
    for (;;) {
        d0 += d0;
        if (d0 & 0x80000000) break;
        d1 = (d1 - 1) & 0xff;
        if (d1 == 0xff) break;
    }
    if (d0 & 0x80) {                        /* half-ulp round up */
        U32 t = d0 + 0x100;
        if (t < d0) { d0 = 0x80000000 | (t >> 1); d1 = (d1 + 1) & 0xff; }
        else d0 = t;
    }
    return (S32)((d0 & 0xffffff00) | (d1 & 0xff));
}

/* ---------------- compare / test ----------------------------------------- */

LONG SPCmp(S32 l __asm("d1"), S32 r __asm("d0"))
{
    U32 cc;
    if (((U32)l & 0x80) && ((U32)r & 0x80)) {   /* both negative: cmp l-r */
        cc = cc_sub((U32)l & 0xff, (U32)r & 0xff, 1);
        if (cc & 4) cc = cc_sub((U32)l, (U32)r, 0);
    } else {                                    /* cmp r-l */
        cc = cc_sub((U32)r & 0xff, (U32)l & 0xff, 1);
        if (cc & 4) cc = cc_sub((U32)r, (U32)l, 0);
    }
    {
        int lt = ((cc >> 3) ^ (cc >> 1)) & 1;
        LONG res = lt ? 1 : ((cc & 4) ? 0 : -1);
        SETCCR(cc);
        return res;
    }
}

LONG SPTst(S32 p __asm("d1"))
{
    U32 b = (U32)p & 0xff;
    U32 cc = (b & 0x80 ? 8 : 0) | (b == 0 ? 4 : 0);
    LONG res = (b & 0x80) ? -1 : (b ? 1 : 0);
    SETCCR(cc);
    return res;
}

/* ---------------- unary -------------------------------------------------- */

LONG SPAbs(S32 p __asm("d0"))
{
    return (S32)((U32)p & 0xffffff7f);      /* no denormal check */
}

LONG SPNeg(S32 p __asm("d0"))
{
    U32 d0 = (U32)p;
    if ((d0 & 0xff) == 0) return (S32)d0;   /* denormal returned unchanged */
    return (S32)(d0 ^ 0x80);
}

/* ---------------- add/sub shared machine --------------------------------- */
/* r0 = d0 operand (B), r1 = d1 operand (A). d4 = effective A byte. */

static S32 as_roxr(U32 s, U32 d4)
{
    s = 0x80000000 | (s >> 1);              /* roxr.l #1 with carry in */
    d4 = (d4 + 1) & 0xff;                   /* addq.b #1 */
    if (d4 == 0x80 || d4 == 0x00) {         /* V(old==7f) or C(old==ff) */
        d4 = (d4 - 1) & 0xff;
        SETV();
        return (S32)(0xffffff00 | d4);      /* moveq #-1 → saturate */
    }
    return (S32)((s & 0xffffff00) | d4);
}

static S32 as_norm(U32 r0, U32 d4)
{
    U32 d5 = d4;                            /* save original byte */
    r0 &= 0xffffff00;
    d4 = (d4 - 1) & 0xff;                   /* subq.b #1 */
    if (r0 <= 0x7fff) { r0 = swp(r0); d4 = (d4 - 16) & 0xff; }
    for (;;) {
        r0 += r0;                           /* add.l d0,d0 */
        if (r0 & 0x80000000) break;         /* dbmi exits when N set */
        d4 = (d4 - 1) & 0xff;
        if (d4 == 0xff) break;              /* dbf exits at -1 */
    }
    d5 ^= d4;
    if (d5 & 0x80) return 0;                /* sign flipped → underflow */
    if (d4 == 0) return 0;
    return (S32)((r0 & 0xffffff00) | d4);
}

static S32 as_addmag(U32 r0, U32 r1, U32 d4, U32 d5)
{
    U32 d3, s;
    d5 = (d5 - d4) & 0xff;                  /* d5 = Bbyte - Aeffbyte */
    if (d5 & 0x80) {                        /* A dominates */
        if (sb8(d5) <= -24) return (S32)((r1 & 0xffffff00) | d4);
        d5 = (-d5) & 0xff;
        r0 = (r0 & 0xffffff00) >> (d5 & 0x1f);   /* align B */
        d3 = (r1 & 0xffffff00) | 0x80;      /* A + 0x80 round seed */
        s = r0 + d3;
        if (s < d3) return as_roxr(s, d4);  /* carry out */
        return (S32)((s & 0xffffff00) | d4);
    }
    d4 = r0 & 0xff;                         /* result byte = B's */
    if (d5 >= 24) return (S32)r0;           /* A shifts away → ret B */
    d3 = (r1 & 0xffffff00) >> (d5 & 0x1f);  /* align A */
    r0 = (r0 & 0xffffff00) | 0x80;
    s = r0 + d3;
    if (s < d3) return as_roxr(s, d4);
    return (S32)((s & 0xffffff00) | d4);
}

static S32 as_machine(U32 r0, U32 r1, int sub)
{
    U32 d4, d5, d3;
    int dest;
    if (sub) {                              /* SPSub entry */
        d4 = r1 & 0xff;
        if (d4 == 0) return (S32)r0;
        d4 ^= 0x80;                         /* negate A */
        if (d4 & 0x80) dest = 1;            /* A eff-neg → 2b0 */
        else {
            d5 = r0 & 0xff;
            dest = (d5 & 0x80) ? 2 : (d5 ? 0 : 3);
        }
    } else {                                /* SPAdd entry */
        d4 = r1 & 0xff;
        if (d4 & 0x80) dest = 1;            /* A neg → 2b0 */
        else if (d4 == 0) return (S32)r0;
        else {
            d5 = r0 & 0xff;
            dest = (d5 & 0x80) ? 2 : (d5 == 0 ? 3 : 0);
        }
    }
    for (;;) {
        if (dest == 1) {                    /* L2b0: B-side dispatch */
            d5 = r0 & 0xff;
            if (d5 & 0x80) dest = 0;        /* B neg → add-mags */
            else if (d5 == 0) dest = 3;
            else dest = 2;
            continue;
        }
        if (dest == 0)                      /* L246: same-sign magnitude add */
            return as_addmag(r0, r1, d4, d5);
        if (dest == 3)                      /* L280: return A (effective byte) */
            return (S32)((r1 & 0xffffff00) | d4);
        /* dest == 2 → L2b6: opposite signs → subtract mags */
        d5 = ((r0 & 0xff) ^ 0x80) & 0xff;
        d5 = (d5 - d4) & 0xff;              /* (Bbyte^80) - Aeffbyte */
        if (d5 == 0) {                      /* L318: equal biased exps */
            d5 = r0 & 0xff;
            { U32 t = d4; d4 = d5; d5 = t; }/* d4=Bbyte, d5=Aeffbyte */
            r0 = (r0 & 0xffffff00) | (r1 & 0xff);
            r0 = r0 - r1;                   /* (mB-mA)<<8 */
            if (r0 == 0) return 0;
            if (r0 & 0x80000000) { r0 = 0u - r0; d4 = d5; }
            return as_norm(r0, d4);
        }
        if (d5 & 0x80) {                    /* L304: A dominates */
            if (sb8(d5) <= -24) { dest = 3; continue; }
            d5 = (-d5) & 0xff;
            d3 = r0;                        /* save B */
            r0 = (r1 & 0xffffff00) | 0x80;  /* Amant<<8|0x80 */
            d3 = (d3 & 0xffffff00) >> (d5 & 0x1f);
            r0 = r0 - d3;
            if (r0 & 0x80000000) return (S32)((r0 & 0xffffff00) | d4);
            return as_norm(r0, d4);
        }
        /* B dominates */
        if (d5 >= 24) return (S32)r0;       /* ret B as-is */
        d4 = r0 & 0xff;                     /* result byte = B's */
        r0 = (r0 & 0xffffff00) | 0x80;
        d3 = (r1 & 0xffffff00) >> (d5 & 0x1f);
        r0 = r0 - d3;
        if (r0 & 0x80000000) return (S32)((r0 & 0xffffff00) | d4);
        return as_norm(r0, d4);
    }
}

LONG SPAdd(S32 l __asm("d1"), S32 r __asm("d0"))
{
    return as_machine((U32)r, (U32)l, 0);
}

LONG SPSub(S32 l __asm("d1"), S32 r __asm("d0"))
{
    return as_machine((U32)r, (U32)l, 1);   /* d0 - d1 */
}

/* ---------------- multiply ------------------------------------------------ */
/* The original's partial-product loop computes exactly (mA*mB)>>16.  muls32
 * is the gcc mulsi3 helper; we keep the 64-bit top half with shifts. */

LONG SPMul(S32 b __asm("d0"), S32 a __asm("d1"))
{
    U32 r0 = (U32)b, r1 = (U32)a;
    U32 d5 = r0 & 0xff;
    U32 d4, d5b, d4b, ssum, resb, p32, nb;
    U32 mA, mB;
    int ssum_s;
    if (d5 == 0) return (S32)r0;            /* B denormal → returned as-is */
    d4 = r1 & 0xff;
    if (d4 == 0) return 0;
    /* byte pack: e*2 with sign→bit8 (word add), then ^0x80 */
    d5b = ((d5 * 2) & 0xff) ^ 0x80;
    d4b = ((d4 * 2) & 0xff) ^ 0x80;
    ssum_s = sb8(d5b) + sb8(d4b);           /* add.b d4,d5 → V test */
    ssum = (d5b + d4b) & 0xff;
    if (ssum_s > 127 || ssum_s < -128) {
        if (!(ssum & 0x80)) return 0;       /* N clear → 0 */
        r0 = (r0 & 0xffffff00) | ((r0 ^ r1) & 0x80);
        r0 |= 0xffffff7f;                   /* saturate to ±0xffffff7f */
        SETV();
        return (S32)r0;
    }
    /* fold: result byte = ((2(eA+eB))^0x80)>>1 | (sA^sB)<<7 */
    resb = (((ssum ^ 0x80) >> 1) & 0x7f) | ((r0 ^ r1) & 0x80);
    /* 24x24→48 product, keep top 32: exact match to asm partial sums */
    mA = r0 >> 8; mB = r1 >> 8;
    {
        U32 a0 = mA & 0xffff, a1 = mA >> 16;
        U32 b0 = mB & 0xffff, b1 = mB >> 16;
        U32 lo = a0 * b0;                   /* 16x16 muls, P<=2^48 */
        /* p32 = P>>16 = a1b1<<16 + a1b0 + a0b1 + a0b0>>16 */
        p32 = (a1 * b1 << 16) + a1 * b0 + a0 * b1 + (lo >> 16);
    }
    if (p32 & 0x80000000) {
        r0 = p32 + 0x80;                    /* round (wrap quirk preserved) */
        if (resb == 0) return 0;
        return (S32)((r0 & 0xffffff00) | resb);
    }
    /* product < 0.5: renormalize left one place */
    if (resb == 0x80 || resb == 0x00) return 0;  /* subq.b V/C → underflow */
    nb = (resb - 1) & 0xff;
    {
        U32 q = p32 + 0x40;
        r0 = q + q;
        if (r0 < q) {                       /* carry out of the double */
            r0 = 0x80000000 | (r0 >> 1);
            nb = (nb + 1) & 0xff;
        }
    }
    if (nb == 0) return 0;
    return (S32)((r0 & 0xffffff00) | nb);
}

/* ---------------- divide -------------------------------------------------- */

LONG SPDiv(S32 n __asm("d0"), S32 d __asm("d1"))
{
    U32 r0 = (U32)n, r1 = (U32)d;
    U32 d5 = r1 & 0xff, d4, d5b, d4b, resb, mDhi, q1, q2, d3, corr, rr;
    int t;
    if (d5 == 0) {
        if (r1 != 0) {
            /* divisor denormal: hardware div-by-zero trap, retried forever */
            __asm volatile("1:\n\t"
                           "divu.w #0,%0\n\t"
                           "tst.l %1\n\t"
                           "bne 1b"
                           : "+d"(r0) : "d"(r1) : "cc");
        }
        r0 |= 0xffffff7f;                   /* exact 0 divisor → saturate +V */
        SETV();
        return (S32)r0;
    }
    d4 = r0;
    if (d4 == 0) return 0;
    /* exp subtract in doubled domain: (2eN^80)-(2eD^80) as signed bytes */
    d5b = ((d5 * 2) & 0xff) ^ 0x80;
    d4b = ((d4 * 2) & 0xff) ^ 0x80;
    t = sb8(d4b) - sb8(d5b);                /* sub.b d5,d4 → V test */
    d4b = t & 0xff;
    if (t > 127 || t < -128) {              /* exp overflow */
        if (d4b & 0x80) {                   /* N set → saturate w/ sign */
            U32 rb = (r0 ^ r1) & 0xff;
            r0 = (r0 & 0xffffff00) | rb;
            r0 |= 0xffffff7f;
            SETV();
            return (S32)r0;
        }
        return 0;
    }
    r0 &= 0xffffff00;                       /* dividend = mN<<8 */
    {
        U32 r0s = swp(r0), r1s = swp(r1);   /* low words = mant hi16s */
        if ((short)(r0s & 0xffff) >= (short)(r1s & 0xffff)) {
            /* mN_hi >= mD_hi → exp += 2(doubled) + prescale dividend /2 */
            int nt = sb8(d4b) + 2;          /* addq.b #2 V test */
            if (nt > 127 || nt < -128) {
                /* 3e2: unswap then eor.b → result byte gets divisor's byte,
                 * so the saturated sign is the DIVISOR's sign (quirk) */
                SETV();
                return (S32)(0xffffff7f | (r1 & 0x80));
            }
            d4b = nt & 0xff;
            r0s = (r0s >> 1) | ((r0s & 1) << 31);       /* ror.l #1 */
        }
        r0 = swp(r0s);
    }
    resb = (((d4b ^ 0x80) >> 1) & 0x7f) | (((U32)n ^ (U32)d) & 0x80);
    mDhi = (r1 >> 16) & 0xffff;             /* swapped d1.w = mD_hi16 */
    {   /* real divu.w: result = rem16:quot16, unchanged on overflow */
        U32 dv = r0;
        __asm volatile("divu.w %1,%0" : "+d"(dv) : "d"(mDhi) : "cc");
        q1 = dv & 0xffff;
    }
    d3 = q1 * mDhi;
    rr = (r0 - d3) & 0xffffffff;
    rr = swp(rr);                           /* rem << 16 */
    corr = (q1 & 0xffff) * (r1 & 0xff00);   /* mulu.w q1 * (mD_lsb<<8) */
    if (rr < corr) {                        /* borrow → q--, rem += divisor */
        rr = (rr - corr) & 0xffffffff;
        for (;;) {
            U32 nr;
            q1 = (q1 - 1) & 0xffff;
            nr = rr + r1;                   /* += full divisor (eD byte incl) */
            rr = nr;
            if (nr < r1) break;             /* carry out → done */
        }
    } else rr -= corr;
    {   /* second divu.w on clrw'd dividend */
        U32 dv = rr & 0xffff0000;
        __asm volatile("divu.w %1,%0" : "+d"(dv) : "d"(mDhi) : "cc");
        q2 = dv & 0xffff;
    }
    {
        U32 q;
        if (q1 & 0x8000) q = (q1 << 16) | q2;
        else { q = ((q1 << 16) | q2) * 2; resb = (resb - 1) & 0xff; }
        q = q + 0x80;                       /* round */
        if (resb == 0) return 0;
        return (S32)((q & 0xffffff00) | resb);
    }
}

/* ---------------- floor / ceil -------------------------------------------- */

static S32 floor_pos(U32 d0)                /* positive (or denormal) operand */
{
    U32 d1 = d0 & 0xff;
    if (d1 == 0) return (S32)d0;            /* byte 0 → returned as-is */
    d0 &= 0xffffff00;
    d1 = (d1 - 0x41) & 0xff;
    if (d1 & 0x80) return 0;                /* |x| < 1 */
    d1 = (d1 - 0x1f) & 0xff;
    if (!(d1 & 0x80)) {                     /* s >= 31 → already integral */
    } else {
        U32 k = (-d1) & 0xff;
        d0 = (d0 >> k) << k;                /* lsr.l d1; lsl.l d1 */
        d1 = (-k) & 0xff;                   /* neg back → s-31 */
    }
    d1 = (d1 + 0x1f) & 0xff;
    d1 = (d1 + 0x41) & 0xff;
    return (S32)((d0 & 0xffffff00) | d1);
}

LONG SPFloor(S32 p __asm("d0"))
{
    U32 d0 = (U32)p;
    if (d0 & 0x80) {                        /* negative: -ceil(|x|) */
        U32 ax = (d0 & 0xff) == 0 ? d0 : (d0 ^ 0x80);   /* SPNeg */
        U32 fl = (U32)floor_pos(ax);
        U32 frac = (U32)as_machine(ax, fl, 1);          /* |x| - floor(|x|) */
        U32 res;
        if (frac & 0xff)                    /* frac nonzero → +1 */
            fl = (U32)as_machine(0x80000041, fl, 0);    /* floor + 1.0 */
        res = ((fl & 0xff) == 0) ? fl : (fl ^ 0x80);    /* SPNeg */
        return (S32)res;
    }
    return floor_pos(d0);
}

LONG SPCeil(S32 p __asm("d0"))
{
    /* bsr SPNeg; bsr SPFloor; bra SPNeg → ceil(x) = -floor(-x) */
    U32 d0 = (U32)p;
    U32 nx = (d0 & 0xff) == 0 ? d0 : (d0 ^ 0x80);
    U32 f = (U32)SPFloor((S32)nx);
    return (S32)(((f & 0xff) == 0) ? f : (f ^ 0x80));
}
