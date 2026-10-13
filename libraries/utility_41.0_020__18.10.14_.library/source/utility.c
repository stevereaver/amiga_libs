/*
 * utility.library 41.0 (18.10.2014) — C reconstruction
 *
 * Compact hand-written utility.library replacement (020-optimised).
 * All public vectors take register arguments like the original.
 *
 * Quirks reproduced from the original:
 *  - FindNamedObject reads caller's a2 as a "previous object" seed;
 *    uninitialised in the original (garbage a2 dereferences a2-16).
 *  - AllocateTagItems allocates exactly n*8 bytes (callers size the
 *    terminator themselves); CloneTagItems counts n+1 and
 *    RefreshTagItemClones writes only a 4-byte terminator longword
 *    (ti_Data stays 0 via MEMF_CLEAR).
 *  - AllocNamedObjectA(NULL) returns 0 (falls to rts with d0=a0).
 *  - ANO_NameSpace value is a boolean: nonzero -> 62-byte namespace
 *    block, zero -> none.  ANO_UserSpace value is the requested
 *    size (+3 for alignment padding).
 *  - the "ns" argument of the named-object calls is an OBJECT
 *    pointer (or NULL -> init's default object at lib+40); its
 *    obj[4] field is the namespace block.  obj[4] is also
 *    overwritten with the owning namespace by AddNamedObject.
 *  - ns flags byte (ns+61): bit0 = dup-check on add, bit1 = use
 *    exec FindName (else a manual Stricmp scan).
 *  - RemNamedObject removal falls through into ReleaseNamedObject
 *    (refcount--, replies stored msg when it hits 0).
 *  - UnpackStructureTags writes through *(ti_Data) as a pointer,
 *    not ti_Data = value.
 *  - Pack/UnpackStructureTags read the table as a longword stream:
 *    only the first {tag,pstg} pair sets the tag; later iterations
 *    consume pstg longwords only (the tag stays stale) until a -1
 *    pstg resyncs a fresh pair.  bit29 (pack) / bit30 (unpack)
 *    entries skip the same single-longword step.  The pack offset
 *    is the sign-extended low word; bit fields pack the bit index
 *    in low-word bits 13..15 and sign-extend byte/word values when
 *    pstg bit31 is set on unpack.
 *  - FreeNamedObject (in utility_lib.s) loads the block into a0
 *    while exec FreeVec reads a1 -> frees the caller's stale a1.
 *  - CallHookPkt tail-jumps to hook[8] (nonstandard Hook layout).
 *  - Expunge/Close never remove the library (-18 is a null stub,
 *    -12 just decrements OpenCnt).
 *  - lib_Revision word is cleared in init (IdString has no $VER:).
 */

typedef unsigned char  UBYTE;
typedef signed char    BYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef short          WORD;
typedef long           LONG;
typedef void          *APTR;
typedef char          *STRPTR;

#ifndef REGPARM_A0
#define REGPARM_A0 __asm("a0")
#define REGPARM_A1 __asm("a1")
#define REGPARM_A2 __asm("a2")
#define REGPARM_A6 __asm("a6")
#define REGPARM_D0 __asm("d0")
#define REGPARM_D1 __asm("d1")
#endif

struct TagItem { ULONG ti_Tag, ti_Data; };
struct Node    { APTR ln_Succ, ln_Pred; UBYTE ln_Type; BYTE ln_Pri;
                 APTR ln_Name; };
struct ExecBase { UBYTE pad[295]; BYTE TDNestCnt; UWORD attn;
                  /* we only touch bytes 294..297 via raw offsets */ };

#define TAG_DONE   0
#define TAG_IGNORE 1
#define TAG_MORE   2
#define TAG_SKIP   3

#define ANO_NameSpace 4000
#define ANO_UserSpace 4001
#define ANO_Priority  4002
#define ANO_Flags     4003

/* private library data (dataSize 0x30): */
struct LibData {
    APTR  sys;        /* +36 */
    APTR  defobj;     /* +40: default named-object (root) */
    ULONG uid;        /* +44: GetUniqueID counter      */
};
#define LIBD(b) ((struct LibData *)((char *)(b) + 36))

/* exec calls used (a6 = SysBase in each stub) */
static APTR x_AllocVec(ULONG size, ULONG attr, APTR sb)
{
    register APTR r __asm("d0"); register ULONG a0 __asm("d0") = size;
    register ULONG a1 __asm("d1") = attr; register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-684)" : "=r"(r) : "r"(a0),"r"(a1),"r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
    return r;
}
static void x_FreeVec(APTR blk, APTR sb)
{
    register APTR a1 __asm("a1") = blk; register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-690)" :: "r"(a1),"r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
}
static void x_Permit(APTR sb)
{
    register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-138)" :: "r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
}
static void x_ObtainSemaphore(APTR sem, APTR sb)
{
    register APTR a0 __asm("a0") = sem; register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-564)" :: "r"(a0),"r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
}
static void x_ObtainSemaphoreShared(APTR sem, APTR sb)
{
    register APTR a0 __asm("a0") = sem; register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-678)" :: "r"(a0),"r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
}
static void x_ReleaseSemaphore(APTR sem, APTR sb)
{
    register APTR a0 __asm("a0") = sem; register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-570)" :: "r"(a0),"r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
}
static void x_InitSemaphore(APTR sem, APTR sb)
{
    register APTR a0 __asm("a0") = sem; register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-558)" :: "r"(a0),"r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
}
static void x_Enqueue(APTR list, APTR node, APTR sb)
{
    register APTR a0 __asm("a0") = list; register APTR a1 __asm("a1") = node;
    register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-270)" :: "r"(a0),"r"(a1),"r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
}
static void x_Remove(APTR node, APTR sb)
{
    register APTR a1 __asm("a1") = node; register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-252)" :: "r"(a1),"r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
}
static APTR x_FindName(APTR list, STRPTR name, APTR sb)
{
    register APTR r __asm("d0"); register APTR a0 __asm("a0") = list;
    register STRPTR a1 __asm("a1") = name; register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-276)" : "=r"(r) : "r"(a0),"r"(a1),"r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
    return r;
}
static void x_ReplyMsg(APTR msg, APTR sb)
{
    register APTR a1 __asm("a1") = msg; register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-378)" :: "r"(a1),"r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
}
static void x_SetFunction(APTR lib, LONG off, APTR fn, APTR sb)
{
    register APTR a1 __asm("a1") = lib; register LONG a0 __asm("a0") = off;
    register APTR a2 __asm("d0") = fn; register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-420)" :: "r"(a1),"r"(a0),"r"(a2),"r"(a6)
                   : "d2","d3","a2","a3","memory","cc");
}

/* ---------------- tag iterators ---------------- */

struct TagItem *NextTagItem(struct TagItem **pp REGPARM_A0)
{
    struct TagItem *it = *pp;
    ULONG tag;
    if (!it) return 0;
    for (;;) {
        tag = it->ti_Tag;
        if (tag == TAG_DONE) { *pp = 0; return 0; }
        if (tag > TAG_SKIP) { *pp = it + 1; return it; }
        if (tag == TAG_SKIP) { it += 1 + it->ti_Data; continue; }
        if (tag == TAG_MORE) {
            ULONG nxt = it->ti_Data;
            if (!nxt) { *pp = 0; return 0; }
            it = (struct TagItem *)nxt;
            continue;
        }
        it++;               /* TAG_IGNORE */
    }
}

struct TagItem *FindTagItem(ULONG tag REGPARM_D0,
                            struct TagItem *list REGPARM_A0)
{
    struct TagItem *p = list, *it;
    while ((it = NextTagItem(&p)))
        if (it->ti_Tag == tag) return it;
    return 0;
}

ULONG GetTagData(ULONG tag REGPARM_D0, ULONG def REGPARM_D1,
                 struct TagItem *list REGPARM_A0)
{
    struct TagItem *it = FindTagItem(tag, list);
    return it ? it->ti_Data : def;
}

ULONG PackBoolTags(ULONG flags REGPARM_D0, struct TagItem *list REGPARM_A0,
                   struct TagItem *map REGPARM_A1)
{
    struct TagItem *p = list, *it;
    while ((it = NextTagItem(&p))) {
        ULONG f = GetTagData(it->ti_Tag, 0, map);
        if (it->ti_Data) flags |= f; else flags &= ~f;
    }
    return flags;
}

void FilterTagChanges(struct TagItem *list REGPARM_A0,
                      struct TagItem *map REGPARM_A1, ULONG apply REGPARM_D0)
{
    struct TagItem *p = list, *it;
    while ((it = NextTagItem(&p))) {
        struct TagItem *m = FindTagItem(it->ti_Tag, map);
        if (!m) continue;
        if (it->ti_Data == m->ti_Data) it->ti_Tag = TAG_IGNORE;
        else if (apply) m->ti_Data = it->ti_Data;
    }
}

void MapTags(struct TagItem *list REGPARM_A0, struct TagItem *map REGPARM_A1,
             ULONG type REGPARM_D0)
{
    struct TagItem *p = list, *it;
    while ((it = NextTagItem(&p))) {
        struct TagItem *m = FindTagItem(it->ti_Tag, map);
        if (m) {
            it->ti_Tag = m->ti_Data;
            if (!it->ti_Tag) it->ti_Tag = TAG_IGNORE;
        } else if (!type) it->ti_Tag = TAG_IGNORE;
    }
}

void ApplyTagChanges(struct TagItem *list REGPARM_A0,
                     struct TagItem *chg REGPARM_A1)
{
    struct TagItem *p = list, *it;
    while ((it = NextTagItem(&p))) {
        struct TagItem *m = FindTagItem(it->ti_Tag, chg);
        if (m) it->ti_Data = m->ti_Data;
    }
}

ULONG TagInArray(ULONG tag REGPARM_D0, ULONG *arr REGPARM_A0)
{
    ULONG v;
    while ((v = *arr++))
        if (v == tag) return 1;
    return 0;
}

ULONG FilterTagItems(struct TagItem *list REGPARM_A0, ULONG *arr REGPARM_A1,
                     ULONG logic REGPARM_D0)
{
    ULONG inv = ((UBYTE)logic == 0), n = 0;
    struct TagItem *p = list, *it;
    while ((it = NextTagItem(&p))) {
        if (TagInArray(it->ti_Tag, arr) ^ inv) it->ti_Tag = TAG_IGNORE;
        else n++;
    }
    return n;
}

/* ---------------- tag item alloc ---------------- */

APTR AllocateTagItems(ULONG n REGPARM_D0, APTR a6 REGPARM_A6)
{
    return x_AllocVec(n << 3, 0x10001, LIBD(a6)->sys);
}

void FreeTagItems(APTR list REGPARM_A0, APTR a6 REGPARM_A6)
{
    x_FreeVec(list, LIBD(a6)->sys);
}

void RefreshTagItemClones(struct TagItem *cl REGPARM_A0,
                          struct TagItem *src REGPARM_A1)
{
    struct TagItem *p = src, *it;
    ULONG *d = (ULONG *)cl;
    while ((it = NextTagItem(&p))) { *d++ = it->ti_Tag; *d++ = it->ti_Data; }
    *d = 0;
}

APTR CloneTagItems(struct TagItem *list REGPARM_A0, APTR a6 REGPARM_A6)
{
    APTR sb = LIBD(a6)->sys;
    struct TagItem *p = list, *cl;
    ULONG n = 0;
    *(BYTE *)((char *)sb + 295) += 1;          /* TDNestCnt++ (Forbid) */
    do { n++; } while (NextTagItem(&p));       /* counts the end call too */
    cl = AllocateTagItems(n, a6);
    if (cl) RefreshTagItemClones(cl, list);
    x_Permit(sb);
    return cl;
}

/* ---------------- clock ---------------- */

static const UBYTE mtab[12] =
    { 31,28,31,30,31,30,31,31,30,31,30,31 };

void Amiga2Date(ULONG secs REGPARM_D0, UWORD *r REGPARM_A0)
{
    ULONG odd  = secs & 1;
    ULONG half = secs >> 1;
    ULONG days = half / 43200;
    ULONG rem  = (half % 43200) * 2 + odd;
    ULONG feb, yr, m, doy;
    LONG  dy;

    r[2] = rem / 3600; rem %= 3600;          /* hour */
    *(ULONG *)r = ((rem % 60) << 16) | (rem / 60); /* sec, min */
    r[6] = days % 7;                          /* wday */
    if (days >= 0xAF7D) days++;               /* 2100 not-leap fix */
    {
        ULONG q = (days + 731) * 4;
        yr  = q / 1461 + 1976;
        doy = (q % 1461) >> 2;
    }
    r[5] = yr;
    feb = (yr == 2100 || (yr & 3)) ? 28 : 29;
    dy = doy;
    m = 1;
    dy -= 31;
    if (dy >= 0) {
        ULONG ml = feb;
        for (;;) {
            m++;
            dy -= ml;
            if (dy < 0) { dy += ml; break; }
            ml = mtab[m];
        }
    } else dy += 31;
    r[3] = dy + 1;                            /* mday */
    r[4] = m;                                 /* month */
}

ULONG Date2Amiga(UWORD *cd REGPARM_A0)
{
    LONG d2 = -1;
    ULONG m = cd[4], y = cd[5], d;
    while (--m) d2 += mtab[m - 1];            /* days before month */
    d = (y - 1977) * 1461 - 1460; d >>= 2;    /* days before year */
    d2 += cd[3];                              /* + mday */
    if (cd[4] > 2 && !(y & 3)) d2++;          /* past feb29 */
    d += d2;
    if (d >= 0xAE4C) d--;                     /* 2100 not-leap fix */
    return d * 86400 + cd[1] * 60 + cd[0] + cd[2] * 3600;
}

ULONG CheckDate(UWORD *cd REGPARM_A0)
{
    UWORD buf[8];
    ULONG secs = Date2Amiga(cd), i;
    Amiga2Date(secs, buf);
    for (i = 0; i < 6; i++) if (buf[i] != cd[i]) return 0;
    return secs;
}

/* ---------------- strings ---------------- */

static ULONG upper_delta(UBYTE c)             /* 32 if in upper-case range */
{
    UBYTE dbl = c + c, lo = 0x82, hi = 0xb4;
    if (c == 0xf7) return 0;
    if (c >= 0x80) { lo = 0x80; hi = 0xbc; }
    return (dbl < lo || dbl > hi) ? 0 : 32;
}
static ULONG lower_delta(UBYTE c)             /* 32 if in lower-case range */
{
    UBYTE dbl = c + c, lo = 0xc2, hi = 0xf4;
    if (c == 0xf7) return 0;
    if (c >= 0x80) { lo = 0xc0; hi = 0xfc; }
    return (dbl < lo || dbl > hi) ? 0 : 32;
}

ULONG ToUpper(ULONG c REGPARM_D0) { return (UBYTE)c - lower_delta((UBYTE)c); }
ULONG ToLower(ULONG c REGPARM_D0) { return (UBYTE)c + upper_delta((UBYTE)c); }

LONG Strnicmp(STRPTR a REGPARM_A0, STRPTR b REGPARM_A1, LONG n REGPARM_D0)
{
    LONG d3 = n; UBYTE ca = 0, cb = 0;
    if (!d3) return 0;
    for (;;) {
        if (--d3 < 0) break;
        ca = (UBYTE)*a++; cb = (UBYTE)*b++;
        if (!cb || !ca) break;
        ca -= lower_delta(ca); cb -= lower_delta(cb);
        if (ca != cb) break;
    }
    return (signed char)(ca - cb);
}
LONG Stricmp(STRPTR a REGPARM_A0, STRPTR b REGPARM_A1)
{
    return Strnicmp(a, b, 0x7fffffff);
}

/* ---------------- pack/unpack structure ---------------- */

ULONG PackStructureTags(UBYTE *pack REGPARM_A0, ULONG *tbl REGPARM_A1,
                        struct TagItem *tags REGPARM_A2)
{
    ULONG n = 0, d2, pstg;
    struct TagItem *it;
    /* original quirk: the table is consumed as a longword stream —
     * only the first pair is {tag,pstg}; every continuation reads
     * pstg-only and leaves the tag register stale until pstg==-1
     * resyncs a fresh {tag,pstg} pair. */
    d2 = *tbl++;
    pstg = *tbl++;
    for (;;) {
        ULONG val; UBYTE *f;
        if (!pstg) break;
        if (pstg == 0xFFFFFFFF) { d2 = *tbl++; pstg = *tbl++; continue; }
        if (pstg & (1L << 29)) { pstg = *tbl++; continue; }
        it = FindTagItem(d2 + ((pstg >> 16) & 0x3ff), tags);
        if (!it) { pstg = *tbl++; continue; }
        n++;
        val = it->ti_Data;
        f = pack + (WORD)(pstg & 0xffff);
        if (pstg & (1L << 28)) {
            if (!(pstg & (1L << 27))) *(ULONG *)f = val;
            else {
                ULONG b = (WORD)(pstg & 0xe000), bit;
                f -= b;
                bit = (UWORD)pstg;
                bit = (UWORD)((bit << 3) | (bit >> 13)) & 7;
                if ((pstg & (1L << 26)) || val) *f |= (UBYTE)(1 << bit);
                else *f &= (UBYTE)~(1 << bit);
                if ((LONG)pstg < 0) *f ^= (UBYTE)(1 << bit);
            }
        } else if (pstg & (1L << 27)) *(UWORD *)f = val;
        else *(UBYTE *)f = val;
        pstg = *tbl++;
    }
    return n;
}

ULONG UnpackStructureTags(UBYTE *pack REGPARM_A0, ULONG *tbl REGPARM_A1,
                          struct TagItem *tags REGPARM_A2)
{
    ULONG n = 0, d2, pstg;
    struct TagItem *it;
    /* same stream reader; bit30 entries are skipped like bit29 in Pack */
    d2 = *tbl++;
    pstg = *tbl++;
    for (;;) {
        ULONG val = 0; UBYTE *f;
        if (!pstg) break;
        if (pstg == 0xFFFFFFFF) { d2 = *tbl++; pstg = *tbl++; continue; }
        if (pstg & (1L << 30)) { pstg = *tbl++; continue; }
        it = FindTagItem(d2 + ((pstg >> 16) & 0x3ff), tags);
        if (!it) { pstg = *tbl++; continue; }
        n++;
        f = pack + (WORD)(pstg & 0xffff);
        if (pstg & (1L << 28)) {
            if (!(pstg & (1L << 27))) val = *(ULONG *)f;
            else {
                ULONG bit;
                f -= (WORD)(pstg & 0xe000);
                bit = (UWORD)pstg;
                bit = (UWORD)((bit << 3) | (bit >> 13)) & 7;
                if (*f & (UBYTE)(1 << bit)) val = ~0;
                if ((LONG)pstg < 0) val = ~val;
            }
        } else if (pstg & (1L << 27)) {
            val = *(UWORD *)f;
            if ((LONG)pstg < 0) val = (LONG)(WORD)val;
        } else {
            val = *(UBYTE *)f;
            if ((LONG)pstg < 0) val = (LONG)(char)val;
        }
        *(ULONG *)it->ti_Data = val;   /* original writes THROUGH ti_Data */
        pstg = *tbl++;
    }
    return n;
}

/* ---------------- named objects ---------------- */

LONG ReleaseNamedObject(APTR obj REGPARM_A0, APTR a6 REGPARM_A6);

static APTR ns_of(APTR o, APTR a6)
{
    if (!o) o = LIBD(a6)->defobj;
    return ((APTR *)o)[1];                       /* object+4 */
}

/* walk ns MinList for name; node = start MinNode */
static struct Node *search_name(APTR ns, STRPTR name, struct Node *node,
                                APTR sb)
{
    if (name) {
        if (((UBYTE *)ns)[61] & 2)               /* NSF_CASE -> FindName */
            return x_FindName(((APTR *)node)[1], name, sb);
        for (;;) {
            struct Node *n = node->ln_Succ;
            if (!n) return 0;
            if (!Stricmp(node->ln_Name, name)) {
                if (!node->ln_Succ) return 0;    /* last node never matches */
                return node;
            }
            node = n;
        }
    }
    return node->ln_Succ ? node : 0;
}

APTR FindNamedObject(APTR nsobj REGPARM_A0, STRPTR name REGPARM_A1,
                     APTR prev REGPARM_A2, APTR a6 REGPARM_A6)
{
    APTR ns = ns_of(nsobj, a6), sb;
    struct Node *node;
    if (!ns) return 0;
    sb = LIBD(a6)->sys;
    x_ObtainSemaphoreShared((char *)ns + 12, sb);
    node = prev ? (struct Node *)*(APTR *)((char *)prev - 16)
                : (struct Node *)*(APTR *)ns;
    node = search_name(ns, name, node, sb);
    if (node) { ((UWORD *)node)[7]++; node = (struct Node *)((char *)node + 16); }
    x_ReleaseSemaphore((char *)ns + 12, sb);
    return node;
}

LONG AddNamedObject(APTR nsobj REGPARM_A0, APTR obj REGPARM_A1,
                    APTR a6 REGPARM_A6)
{
    APTR ns = ns_of(nsobj, a6), sb;
    struct Node *node;
    LONG ok;
    if (!ns || !obj) return 0;
    sb = LIBD(a6)->sys;
    node = (struct Node *)((char *)obj - 16);
    x_ObtainSemaphore((char *)ns + 12, sb);
    ok = -1;
    if (((UBYTE *)ns)[61] & 1)                    /* NSF_NODUPS */
        if (search_name(ns, node->ln_Name, *(APTR *)ns, sb)) ok = 0;
    if (ok) {
        x_Enqueue(ns, node, sb);
        ((APTR *)node)[5] = ns;                  /* node+20 = object+4 */
    }
    x_ReleaseSemaphore((char *)ns + 12, sb);
    return ok;
}

LONG RemNamedObject(APTR obj REGPARM_A0, APTR msg REGPARM_A1,
                    APTR a6 REGPARM_A6)
{
    APTR sb = LIBD(a6)->sys, ns;
    *(BYTE *)((char *)sb + 295) += 1;
    ns = ((APTR *)obj)[1];
    if (ns && (msg || ((UWORD *)obj)[-1] == 1)) {
        ((APTR *)obj)[1] = 0;
        x_ObtainSemaphore((char *)ns + 12, sb);
        x_Remove((char *)obj - 16, sb);
        ((APTR *)obj)[2] = msg;
        if (msg) *(APTR *)((char *)msg + 10) = obj;
        x_ReleaseSemaphore((char *)ns + 12, sb);
        x_Permit(sb);
        return ReleaseNamedObject(obj, a6);      /* falls through in original */
    }
    if (msg) { *(ULONG *)((char *)msg + 10) = 0; x_ReplyMsg(msg, sb); }
    x_Permit(sb);
    return (LONG)msg;
}

LONG ReleaseNamedObject(APTR obj REGPARM_A0, APTR a6 REGPARM_A6)
{
    APTR sb;
    if (!obj) return 1;
    sb = LIBD(a6)->sys;
    *(BYTE *)((char *)sb + 295) += 1;
    if (!--((UWORD *)obj)[-1] && ((APTR *)obj)[2])
        x_ReplyMsg(((APTR *)obj)[2], sb);
    x_Permit(sb);
    return 1;
}

APTR NamedObjectName(APTR obj REGPARM_A0)
{
    return obj ? *(APTR *)((char *)obj - 6) : 0;
}

/* FreeNamedObject lives in utility_lib.s: the original loads the
 * block into a0 but exec FreeVec reads a1, so it frees whatever
 * stale pointer was in the caller's a1 (reproduced in asm). */

APTR AllocNamedObjectA(STRPTR name REGPARM_A0, struct TagItem *tags REGPARM_A1,
                       APTR a6 REGPARM_A6)
{
    APTR sb, blk, obj;
    ULONG ns, us, nl;
    STRPTR s;
    UBYTE *np, *d;
    if (!name) return (APTR)name;                /* quirk: returns a0 (=0) */
    sb = LIBD(a6)->sys;
    ns = GetTagData(ANO_NameSpace, 0, tags); if (ns) ns = 62;
    us = GetTagData(ANO_UserSpace, 0, tags); if (us) us += 3;
    nl = 28;
    s = name;
    do { nl++; } while (*s++);                   /* 28 + strlen + 1 */
    blk = x_AllocVec(nl + ns + us, 0x10001, sb);
    if (!blk) return 0;
    np = (UBYTE *)blk + 28;
    if (ns) { *(APTR *)((char *)blk + 20) = np; np += ns; }
    *(APTR *)((char *)blk + 10) = np;            /* node ln_Name */
    d = np;
    while ((*d++ = *name++));
    obj = (UBYTE *)blk + 16;
    if (us) *(APTR *)obj = (APTR)(((ULONG)d + 3) & ~3UL);
    if (*(APTR *)((char *)obj + 4)) {            /* namespace block present */
        UBYTE *nb = *(UBYTE **)((char *)obj + 4);
        *(ULONG *)(nb + 58) = GetTagData(ANO_Flags, 0, tags);
        *(APTR *)(nb + 8) = nb;
        *(ULONG *)(nb + 4) = 0;
        *(APTR *)nb = nb + 4;                    /* empty MinList */
        x_InitSemaphore(nb + 12, sb);
    }
    *(BYTE *)((char *)obj - 7) = GetTagData(ANO_Priority, 0, tags);
    ((UWORD *)obj)[-1] += 1;
    return obj;
}

ULONG GetUniqueID(APTR a6 REGPARM_A6)
{
    APTR sb = LIBD(a6)->sys;
    ULONG id;
    *(volatile UWORD *)0xdff09a = 0x4000;        /* INTENA: clr master */
    *(BYTE *)((char *)sb + 294) += 1;            /* IDNestCnt++ */
    id = ++LIBD(a6)->uid;
    if ((--*(BYTE *)((char *)sb + 294)) < 0)
        *(volatile UWORD *)0xdff09a = 0xc000;    /* INTENA: set master */
    return id;
}

/* ---------------- lifecycle ---------------- */

APTR LibOpen(APTR a6 REGPARM_A6)
{
    ((UWORD *)a6)[16]++;                          /* lib_OpenCnt */
    return a6;
}
LONG LibClose(APTR a6 REGPARM_A6)
{
    ((UWORD *)a6)[16]--;
    return 0;
}
LONG LibExpunge(void) { return 0; }
LONG LibReserved(void) { return 0; }

extern const UBYTE patchtab[];                  /* {w off, l fn} * 6 */

APTR LibInit(APTR lib REGPARM_D0, APTR a6 REGPARM_A6)
{
    static const ULONG itags[3] = { ANO_NameSpace, 1, 0 };
    static const char  ename[1] = "";
    LIBD(lib)->sys = a6;
    ((UWORD *)lib)[11] = 0;                       /* lib_Revision = 0 */
    LIBD(lib)->defobj = AllocNamedObjectA((STRPTR)ename,
                                          (struct TagItem *)itags, lib);
    if (((UBYTE *)a6)[297] & 0x8e) {              /* 020/030/040/060 */
        const UBYTE *p = patchtab;
        LONG i, n = (((UBYTE *)a6)[297] & 0x80) ? 1 : 5;
        for (i = 0; i <= n; i++, p += 6)
            x_SetFunction(lib, *(const WORD *)p,
                          *(APTR *const *)(p + 2), a6);
    }
    return lib;
}
