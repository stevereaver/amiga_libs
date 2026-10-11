/*
 * rexxapp.library "(dissidents Jan 91)" - ARexx application host library.
 *
 * Reconstructed from the 1568-byte binary.  The library presents a raw
 * JMP-table vector set and an unusual ABI: every public function reads
 * the *application context* from A5 (never set by the library itself -
 * the caller must load it).  The context embeds a full MsgPort at +0
 * which is registered under the caller-supplied name; incoming ARexx
 * commands are matched against a verb table at +62 and dispatched to the
 * app's handler at +38.  Unmatched commands can be forwarded to the real
 * "REXX" port with the reply chained back to the original sender via
 * args[14]/args[15] of the outbound RexxMsg.
 */

typedef unsigned char  UBYTE;
typedef short          WORD;
typedef unsigned short UWORD;
typedef long           LONG;
typedef unsigned long  ULONG;
typedef char          *STRPTR;
typedef void          *APTR;

/* ---- application context (register A5, owned by the caller) -------- */
struct RaxCmd { STRPTR verb; APTR data; };

struct RaxCtx {
    /* +0  struct MsgPort (34 bytes) */
    APTR   mp_Succ;           /*  0 */
    APTR   mp_Pred;           /*  4 */
    UBYTE  mp_Type;           /*  8  NT_MSGPORT */
    UBYTE  mp_Pri;            /*  9 */
    STRPTR mp_Name;           /* 10 */
    UBYTE  mp_Flags;          /* 14 */
    UBYTE  mp_SigBit;         /* 15  bit7 = "initialising" */
    APTR   mp_SigTask;        /* 16 */
    APTR   mp_Head;           /* 20 */
    APTR   mp_Tail;           /* 24 */
    APTR   mp_TailPred;       /* 28 */
    /* +32 */
    UBYTE  flags;             /* bit7 = shutting down */
    UBYTE  pending;           /* outstanding sent msgs */
    STRPTR ext;               /* +34 file extension / forward enable */
    APTR   handler;           /* +38 app command handler */
    APTR   rxs;               /* +42 rexxsyslib base */
    APTR   cb_res;            /* +46 result callback   */
    APTR   cb_err;            /* +50 error callback    */
    ULONG  waitmask;          /* +54 1<<sigbit         */
    ULONG  pad58;             /* +58 */
    struct RaxCmd cmds[1];    /* +62 {verb,data} pairs, verb NULL ends */
};

/* ---- RexxMsg (rexx/storage.h layout, 128 bytes) -------------------- */
struct RMsg {
    APTR   n_succ, n_pred;            /*  0,4  */
    UBYTE  n_type, n_pri;             /*  8,9  */
    APTR   n_name;                    /* 10    */
    APTR   replyport;                 /* 14    */
    UWORD  n_len;                     /* 18    */
    APTR   taskblock, libbase;        /* 20,24 */
    LONG   action;                    /* 28    */
    LONG   r1, r2;                    /* 32,36 */
    APTR   args[16];                  /* 40..103 (15=reply cb, 14=orig) */
    APTR   passport;                  /* 104 */
    STRPTR commaddr;                  /* 108 */
    STRPTR fileext;                   /* 112 */
    LONG   rstdin, rstdout, ravail;   /* 116,120,124 */
};

#define RXCOMM      0x01000000L
#define RXFF_RESULT (1L<<17)
#define RXFF_STRING (1L<<18)
#define RXFF_NONRET (1L<<20)

/* the library's stored execbase lives at libbase+38 (emitted by lib.s) */
extern APTR rx_exec;

/* caller-provided context register (documented ABI of this library) */
register struct RaxCtx *CTX __asm("a5");

/* ---- raw exec LVO helpers ------------------------------------------ */
static void ex_forbid(void)
{ register APTR __e __asm("a6") = rx_exec;
  __asm volatile("jsr a6@(-132:W)\n" ::"r"(__e):"d0","d1","a0","a1","cc","memory"); }
static void ex_permit(void)
{ register APTR __e __asm("a6") = rx_exec;
  __asm volatile("jsr a6@(-138:W)\n" ::"r"(__e):"d0","d1","a0","a1","cc","memory"); }
static LONG ex_allocsig(LONG n)
{ register LONG __r __asm("d0") = n; register APTR __e __asm("a6") = rx_exec;
  __asm volatile("jsr a6@(-330:W)\n" : "+r"(__r) :"r"(__e):"d1","a0","a1","cc","memory");
  return __r; }
static void ex_freesig(LONG n)
{ register LONG __p __asm("d0") = n; register APTR __e __asm("a6") = rx_exec;
  __asm volatile("jsr a6@(-336:W)\n" ::"r"(__e),"r"(__p):"d1","a0","a1","cc","memory"); }
static void ex_addport(APTR p)
{ register APTR __p __asm("a1") = p; register APTR __e __asm("a6") = rx_exec;
  __asm volatile("jsr a6@(-354:W)\n" ::"r"(__e),"r"(__p):"d0","d1","a0","cc","memory"); }
static void ex_remport(APTR p)
{ register APTR __p __asm("a1") = p; register APTR __e __asm("a6") = rx_exec;
  __asm volatile("jsr a6@(-360:W)\n" ::"r"(__e),"r"(__p):"d0","d1","a0","cc","memory"); }
static void ex_putmsg(APTR port, APTR m)
{ register APTR __p __asm("a0") = port; register APTR __m __asm("a1") = m;
  register APTR __e __asm("a6") = rx_exec;
  __asm volatile("jsr a6@(-366:W)\n" ::"r"(__e),"r"(__p),"r"(__m):"d0","d1","cc","memory"); }
static APTR ex_getmsg(APTR port)
{ register APTR __p __asm("a0") = port; register APTR __e __asm("a6") = rx_exec;
  register APTR __r __asm("d0");
  __asm volatile("jsr a6@(-372:W)\n" : "=r"(__r) :"r"(__e),"r"(__p):"d1","a1","cc","memory");
  return __r; }
static void ex_reply(APTR m)
{ register APTR __p __asm("a1") = m; register APTR __e __asm("a6") = rx_exec;
  __asm volatile("jsr a6@(-378:W)\n" ::"r"(__e),"r"(__p):"d0","d1","a0","cc","memory"); }
static APTR ex_waitport(APTR port)
{ register APTR __p __asm("a0") = port; register APTR __e __asm("a6") = rx_exec;
  register APTR __r __asm("d0");
  __asm volatile("jsr a6@(-384:W)\n" : "=r"(__r) :"r"(__e),"r"(__p):"d1","a1","cc","memory");
  return __r; }
static APTR ex_findport(STRPTR nm)
{ register STRPTR __p __asm("a1") = nm; register APTR __e __asm("a6") = rx_exec;
  register APTR __r __asm("d0");
  __asm volatile("jsr a6@(-390:W)\n" : "=r"(__r) :"r"(__e),"r"(__p):"d1","a0","cc","memory");
  return __r; }
static APTR ex_openlib(STRPTR nm)
{ register STRPTR __p __asm("a1") = nm; register APTR __r __asm("d0") = 0;
  register APTR __e __asm("a6") = rx_exec;
  __asm volatile("jsr a6@(-552:W)\n" : "+r"(__r) :"r"(__e),"r"(__p):"d1","a0","cc","memory");
  return __r; }
static void ex_closelib(APTR l)
{ register APTR __p __asm("a1") = l; register APTR __e __asm("a6") = rx_exec;
  __asm volatile("jsr a6@(-414:W)\n" ::"r"(__e),"r"(__p):"d0","d1","a0","cc","memory"); }

/* ---- rexxsyslib calls (a6 = ctx->rxs) ------------------------------- */
static APTR rxs_createmsg(APTR port, STRPTR ext, STRPTR host)
{ register APTR __p __asm("a0") = port; register STRPTR __x __asm("a1") = ext;
  register APTR __r __asm("d0") = (APTR)host; register APTR __e __asm("a6") = CTX->rxs;
  __asm volatile("jsr a6@(-144:W)\n" : "+r"(__r) :"r"(__e),"r"(__p),"r"(__x):"d1","cc","memory");
  return __r; }
static void rxs_delmsg(APTR m)
{ register APTR __p __asm("a0") = m; register APTR __e __asm("a6") = CTX->rxs;
  __asm volatile("jsr a6@(-150:W)\n" ::"r"(__e),"r"(__p):"d0","d1","a1","cc","memory"); }
static void rxs_delarg(APTR s)
{ register APTR __p __asm("a0") = s; register APTR __e __asm("a6") = CTX->rxs;
  __asm volatile("jsr a6@(-132:W)\n" ::"r"(__e),"r"(__p):"d0","d1","a1","cc","memory"); }
static APTR rxs_priv96(ULONG v)
{ register ULONG __p __asm("d0") = v; register APTR __e __asm("a6") = CTX->rxs;
  register APTR __r __asm("a0");
  __asm volatile("jsr a6@(-96:W)\n" : "=r"(__r),"+r"(__p) :"r"(__e):"d1","a1","cc","memory");
  return __r; }
static APTR rxs_argstring(STRPTR s, ULONG len)
{ register STRPTR __p __asm("a0") = s; register ULONG __l __asm("d0") = len;
  register APTR __e __asm("a6") = CTX->rxs; register APTR __r __asm("d0");
  __asm volatile("jsr a6@(-126:W)\n" : "+r"(__r) :"r"(__e),"r"(__p),"r"(__l):"d1","a1","cc","memory");
  return __r; }

/* ctx cb convention: stack args (ctx, msg, a0, d0) as at 0x12a          */
static ULONG call_ctxcb(APTR fn, struct RMsg *m, APTR a0v, LONG d0v)
{ register APTR __f __asm("a6") = fn; register struct RMsg *__m __asm("a2") = m;
  register APTR __a0 __asm("a0") = a0v; register LONG __d0 __asm("d0") = d0v;
  __asm volatile("moveml a5/a2/a0/d0,sp@-\n\tjsr a6@\n\tlea sp@(16),sp\n"
      : "+r"(__d0) :"r"(__f),"r"(__m),"r"(__a0):"a1","d1","cc","memory");
  return __d0; }
/* args15 cb convention: register args a0=msg,d0=r1,d1=r2 (the 0x1a4 jmp) */
static ULONG call_arg15(APTR fn, struct RMsg *m, LONG d0v, LONG d1v)
{ register APTR __a0 __asm("a0") = m; register LONG __d0 __asm("d0") = d0v;
  register LONG __d1 __asm("d1") = d1v; register APTR __f __asm("a6") = fn;
  __asm volatile("jsr a6@\n" : "+r"(__d0),"+r"(__a0),"+r"(__d1)
      :"r"(__f):"a1","cc","memory");
  return __d0; }
/* validator convention: stack args (ctx, msg), fn in a1 (the 0x324 jsr) */
static ULONG call_a1(APTR fn, struct RMsg *m)
{ register APTR __f __asm("a1") = fn; register struct RMsg *__m __asm("a2") = m;
  register ULONG __d0 __asm("d0");
  __asm volatile("moveml a5/a2,sp@-\n\tjsr a1@\n\tmoveml sp@+,a5/a2\n"
      : "=r"(__d0) :"r"(__f),"r"(__m):"a0","d1","cc","memory");
  return __d0; }
/* call the app handler in a0 (a2=msg,a3=data,a4=rest,a5=ctx)            */
static LONG call_handler(APTR fn, struct RMsg *m, APTR data, STRPTR rest)
{ register APTR __f __asm("a0") = fn; register struct RMsg *__m __asm("a2") = m;
  register APTR __d __asm("a3") = data; register STRPTR __r __asm("a4") = rest;
  register LONG __d0 __asm("d0");
  __asm volatile("jsr a0@\n" : "=r"(__d0),"+r"(__m),"+r"(__d),"+r"(__r)
      :"r"(__f):"a1","d1","cc","memory");
  return __d0; }

/* ---- error strings -------------------------------------------------- */
static const char s_noserver[] = "Can't find Rexx server";
static const char s_norsx[]    = "Can't find rexxsyslib.library";
static const char s_rxslib[]   = "rexxsyslib.library";
static const char s_noport[]   = "Rexx port not setup";
static const char s_toomany[]  = "Too many Rexx msgs";
static const char s_nomem[]    = "No mem for Rexx msg";
static const char s_severe[]   = "Severe RETURN or EXIT";
static const char s_rexx[]     = "REXX";

static ULONG slen(STRPTR s)
{ STRPTR p = s; while (*p) p++; return (ULONG)(p - s); }

/* bump exec TDNestCnt (+0x127) - the manual Forbid the original uses    */
#define tdnest_inc()  (*(UBYTE *)((UBYTE *)rx_exec + 0x127)) += 1
#define thistask()    (*(APTR *)((UBYTE *)rx_exec + 276))

/* lazy-open rexxsyslib (0x28a)                                          */
static APTR ensure_rxs(void)
{
    APTR d0 = CTX->rxs;
    if (!d0) { d0 = ex_openlib((STRPTR)s_rxslib); CTX->rxs = d0; }
    return d0;
}

/* shared tail: close rexxsyslib when nothing is outstanding (0x412)     */
static void maybe_close(void)
{
    if (CTX->pending == 0) {
        APTR *slot = &CTX->rxs;
        APTR d1 = *slot;
        if (d1) { *slot = 0; ex_closelib(d1); }
    }
}

/* free a RexxMsg + its argstring honouring the action flags (0x374)     */
static void freemsg(APTR arg0, struct RMsg *msg, ULONG action)
{
    if (CTX->rxs && !(action & RXFF_STRING))
        rxs_delarg(arg0);
    if (msg) {
        if (!(action & RXFF_NONRET)) CTX->pending--;
        if (action & RXFF_RESULT) {
            if (!msg->r1 && msg->r2) rxs_delarg((APTR)msg->r2);
        }
        rxs_delmsg(msg);
    }
    maybe_close();
}

/* result callback dispatcher for replies to our sends (0xfc)            */
static void resultproc(struct RMsg *msg, LONG r1, LONG r2)
{
    APTR a0;
    if (r1) {
        if (!r2) {
            LONG d1 = 20 - r1;                       /* severity check   */
            if ((ULONG)r1 > 20)                      /* blss on 20-r1    */
                call_ctxcb(CTX->cb_res, msg, (APTR)s_severe, r1);
            else
                call_ctxcb(CTX->cb_err, msg, 0, r1);
        } else {
            APTR res = rxs_priv96((ULONG)r2);
            call_ctxcb(CTX->cb_res, msg, (UBYTE *)res + 8, r2);
        }
    } else {
        LONG d0 = r2;
        a0 = 0;
        if (((UBYTE *)&msg->action)[1] & 2) {   /* btst #1,msg+29       */
            a0 = (APTR)d0; d0 = 0;
        }
        call_ctxcb(CTX->cb_err, msg, a0, d0);
    }
}

/* shared send body (0x2a8): cb->args15, orig->args14                    */
static APTR send_body(STRPTR cmd, APTR cb, struct RMsg *orig,
                      ULONG action, APTR portfn)
{
    struct RMsg *msg;
    STRPTR argstr;
    APTR port;

    const char *a4;
    if (CTX->mp_SigBit & 0x80) { a4 = s_noport; goto err0; }
    if ((UBYTE)(CTX->pending + 1) == 0) { a4 = s_toomany; goto err0; }
    if (!ensure_rxs()) { a4 = s_norsx; goto err0; }

    argstr = 0;
    msg = rxs_createmsg(CTX, CTX->ext, CTX->mp_Name);
    if (!msg) { a4 = s_nomem; goto failfree; }

    msg->action = action;
    if (!(action & RXFF_NONRET)) CTX->pending++;
    if (action & RXFF_STRING) {
        argstr = cmd;
    } else {
        argstr = rxs_argstring(cmd, slen(cmd));
    }
    msg->args[0]  = argstr;
    if (!argstr) { a4 = s_nomem; goto failfree; }
    msg->n_name   = CTX->mp_Name;
    msg->args[15] = cb;
    msg->args[14] = orig;
    if (portfn) {
        ULONG d0 = call_a1(portfn, msg);
        if (d0) { a4 = (const char *)d0; goto failfree; } /* validator */
    }
    ex_forbid();
    port = ex_findport((STRPTR)s_rexx);
    if (port) ex_putmsg(port, msg);
    ex_permit();
    if (port) return msg;
    a4 = s_noserver;
failfree:
    freemsg(argstr, msg, action);
err0:
    {
        register const char *__e0 __asm("a0") = a4;
        __asm volatile("" ::"r"(__e0):);
    }
    return 0;
}

/* shared setresult sub (0x3e0): fills r1/r2, optional argstring conv    */
static void setresult(struct RMsg *m, LONG d0, LONG d1, APTR a0)
{
    m->r2 = d1;
    m->r1 = d0;
    if (d0 != 0) { maybe_close(); return; }
    if (!(((UBYTE *)&m->action)[1] & 2)) { maybe_close(); return; }
    if (!a0) { m->r2 = 0; maybe_close(); return; }
    m->r2 = ensure_rxs() ? (LONG)rxs_argstring((STRPTR)a0, slen((STRPTR)a0)) : 0;
    maybe_close();
}

/* the 0x3b6 forwarder: reply cb for forwarded sends                     */
static void fwd_reply(void)
{
    register struct RMsg *__a0 __asm("a0");
    register LONG __d0 __asm("d0");
    register LONG __d1 __asm("d1");
    struct RMsg *orig = (struct RMsg *)__a0->args[14];
    setresult(orig, __d0, __d1, 0);
    ex_reply(orig);
}

/* dispatch body shared by -36 and -42 (0x194)                           */
static void dispatch_body(void)
{
    struct RMsg *msg;
    if (CTX->mp_SigBit & 0x80) return;      /* still initialising */
    for (;;) {
        msg = ex_getmsg(CTX);
        if (!msg) return;
        {
            STRPTR a4 = (STRPTR)msg->args[0];
            ULONG action;
            if (msg->replyport == (APTR)CTX) {          /* reply to our send */
                resultproc(msg, msg->r1, msg->r2);
                if (msg->args[15])
                    call_arg15(msg->args[15], msg, msg->r1, msg->r2);
                action = msg->action;
                freemsg(a4, msg, action);
                continue;
            }
            /* incoming command: strip leading space/tab from arg0 */
            while (*a4 == ' ' || *a4 == '\t') a4++;
            {
                struct RaxCmd *a3 = CTX->cmds;
                msg->r1 = msg->r2 = 0;
                if (CTX->flags & 0x80) {
                    ((UBYTE *)&msg->r1)[3] = 100;        /* shutting down */
                    ex_reply(msg);
                    continue;
                }
                for (;;) {
                    STRPTR v = a3->verb;
                    STRPTR p, q;
                    UBYTE c0, c1;
                    int matched = 0;
                    if (!v) {
                        /* no verb matched: forward to REXX or error 30 */
                        msg->fileext = CTX->ext;
                        if (CTX->ext)
                            send_body(a4, fwd_reply, msg, RXCOMM, 0);
                        else {
                            ((UBYTE *)&msg->r1)[3] = 30;
                            ex_reply(msg);
                        }
                        break;
                    }
                    /* case-folded verb compare (reproduces fold quirks) */
                    p = v; q = a4;
                    for (;;) {
                        c0 = (UBYTE)*p++;
                        if (!c0) { matched = 1; break; }
                        c1 = (UBYTE)*q++;
                        if (c0 == c1) continue;
                        c1 |= 0x20;
                        if (c0 != c1) break;
                        if (c1 <= 97) break;                /* bhis quirk  */
                        if (c1 >= 122) break;                /* !blss quirk */
                    }
                    if (matched) {
                        LONG rc;
                        a4 = q;
                        rc = call_handler(CTX->handler, msg, a3->data, a4);
                        if (rc) ex_reply(msg);   /* nonzero -> lib replies */
                        break;
                    }
                    a3++;                              /* skip data long    */
                }
            }
        }
    }
}

/* ------------------------------------------------------------------ */
/* -36 RAX_Dispatch: service port messages                              */
void rax_dispatch(void)
{
    dispatch_body();
}

/* -42 RAX_Cleanup: flag shutdown, drain, free sigbit, remove port      */
void rax_cleanup(void)
{
    CTX->flags |= 0x80;
    for (;;) {
        dispatch_body();
        if (!CTX->pending) break;
        ex_waitport(CTX);
    }
    {
        UBYTE *a0 = &CTX->mp_SigBit;
        LONG d0 = (signed char)*a0;
        if (d0 >= 0) {
            *a0 |= 0x80;
            ex_freesig(d0);
            ex_remport(CTX);
        }
    }
    CTX->flags &= ~0x80;
    maybe_close();
}

/* -30 RAX_Setup(a1=portname): claim unique name, alloc sig, AddPort    */
ULONG rax_setup(void)
{
    register STRPTR name __asm("a1");
    STRPTR a1;
    LONG d2 = 8;
    LONG d0;

    CTX->mp_Name = name;
    CTX->mp_SigBit |= 0x80;                 /* mark initialising */
    tdnest_inc();                            /* manual Forbid   */
    for (;;) {
        a1 = CTX->mp_Name;
        if (!ex_findport(a1)) goto initport;    /* free name -> create */
        a1 = CTX->mp_Name;
        while (*a1) a1++;                       /* a1 = NUL+1 via @+ */
        a1++;
        if (d2 & 0x80000000L) a1--;
        d2 |= 0x80000000L;
        a1[-1] = (char)(58 - (UBYTE)d2);        /* '2'..'9',':'        */
        a1[0] = 0;
        if ((UWORD)(--d2) != 0xffff) continue;  /* dbf: 8..0 = 9 tries */
        break;                                  /* exhausted -> error  */
    }
    goto done;

initport:
    {
        UBYTE *p = (UBYTE *)CTX;
        ((APTR *)p)[0] = 0;                       /* Succ            */
        ((APTR *)p)[1] = 0;                       /* Pred            */
        p[8]  = 4;                                /* NT_MSGPORT      */
        p[9]  = 0;
        p[14] = 0;                                /* PA_SIGNAL       */
        ((APTR *)p)[5] = (APTR)&((APTR *)p)[6];   /* head -> tail    */
        ((APTR *)p)[7] = (APTR)&((APTR *)p)[5];   /* tailpred->head  */
        ((APTR *)p)[6] = 0;                       /* tail = NULL     */
        *(UWORD *)(p + 32) = 0;                   /* flags + pending */
        CTX->rxs     = 0;
        d0 = ex_allocsig(-1);
        CTX->mp_SigTask = thistask();
        CTX->mp_SigBit  = (UBYTE)d0;              /* clears init flag */
        if (d0 >= 0)
            ex_addport(CTX);
    }
done:
    ex_permit();
    {
        LONG d1 = (signed char)CTX->mp_SigBit;
        if (d1 < 0) {
            register const char *__e0 __asm("a0") = s_noport;
            __asm volatile("" ::"r"(__e0):);
            return 0;                           /* a0 = s_noport   */
        }
        d0 = 1L << d1;
        CTX->waitmask = (ULONG)d0;
        return (ULONG)d0;
    }
}

/* -48 RAX_SendEx(a0=cmd,a1=cb,a2=orig,d0=action,d1=portfn)             */
APTR rax_send(void)
{
    register STRPTR __a0 __asm("a0");
    register APTR   __a1 __asm("a1");
    register APTR   __a2 __asm("a2");
    register ULONG  __d0 __asm("d0");
    register APTR   __d1 __asm("d1");
    return send_body(__a0, __a1, (struct RMsg *)__a2, __d0, __d1);
}

/* -54 RAX_SendCommand(a0=cmd): RXCOMM, no callback                      */
APTR rax_sendcmd(void)
{
    register STRPTR __a0 __asm("a0");
    register APTR   __a2 __asm("a2");
    return send_body(__a0, 0, (struct RMsg *)__a2, RXCOMM, 0);
}

/* -60 RAX_SendForward(a0=cmd): RXCOMM with auto-forward reply           */
APTR rax_sendfwd(void)
{
    register STRPTR __a0 __asm("a0");
    register APTR   __a2 __asm("a2");
    return send_body(__a0, fwd_reply, (struct RMsg *)__a2, RXCOMM, 0);
}

/* -66 RAX_SetResult(a1=msg,d0=r1,d1=r2,a0=str)                          */
void rax_result(void)
{
    register struct RMsg *__a1 __asm("a1");
    register LONG __d0 __asm("d0");
    register LONG __d1 __asm("d1");
    register APTR __a0 __asm("a0");
    setresult(__a1, __d0, __d1, __a0);
}
