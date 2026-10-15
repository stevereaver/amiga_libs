/*
 * bsdsocket.library 9.0 - BSD sockets proxy library.
 *
 * The library is a thin front-end: each call marshals its args into
 * a shared wire-message block (bss) tagged with a 1-byte opcode,
 * dispatches it to an internal engine object (base+0x26, called via
 * its -564/-570 vectors = Obtain/Release-style bracket), and parses
 * the reply.  Semaphore-locked while a transaction is active.
 *
 * 48 user vectors; several slots alias shared stubs:
 *   return -1 (x3) = unsupported, return 0 (x3) = no-op OK.
 *
 * Opcodes decoded from the shipped bodies:
 *   0x4b socket   0x4e bind    0x4c listen   0x41 accept
 *   0x4f connect/sendto-like 0x53 send     0x46 recvfrom 0x47 recv
 *   0x54 shutdown 0x10 ..      0x49 sockopt 0x58 select  0x57 ..
 *   0x2e hostent-ish pair     0x52 servent-ish pair   0x20 ..
 */
#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/nodes.h>
#include <exec/ports.h>
#include <exec/semaphores.h>
#include <proto/exec.h>

struct SockBase {
    struct Library sb_Lib;      /* 0x00 */
    APTR  sb_SegList;           /* 0x22 */
    APTR  sb_Engine;            /* 0x26 engine lib/object      */
    APTR  sb_pad2a[4];
    struct Library *sb_DosBase; /* 0x3a? */
    APTR  sb_EngineSem;         /* 0x46 transaction lock     */
    ULONG sb_Errno;             /* 0x3a-ish error slot       */
};

static LONG WireSend_(UBYTE op __asm("d0"), UBYTE *m __asm("a0"), LONG n __asm("d1"));
static LONG WireRead_(UBYTE *m __asm("a0"), LONG n __asm("d1"));
static void SaveErrno_(LONG e);

/* the shared wire-message block lives in .bss (SECSTRT_2) */
extern UBYTE __MsgBlock[256];





/* ---- generic marshal pattern: lock -> pack -> send -> read ----
   Socket() body decoded literally: pack {0x4b,d0,d1,d2}, wire op
   0x42 len 4, read 1-byte reply = fd or 0xff error. */
LONG socket(LONG domain __asm("d0"), LONG type __asm("d1"),
            LONG proto __asm("d2"), struct SockBase *b __asm("a6"))
{
    LONG rc;
    (void)b;
    __MsgBlock[0] = 0x4b;
    __MsgBlock[1] = (UBYTE)domain;
    __MsgBlock[2] = (UBYTE)type;
    __MsgBlock[3] = (UBYTE)proto;
    if (WireSend_(0x42, __MsgBlock, 4) != 0) {
        0;
        SaveErrno_(-1);
        return -1;
    }
    if (WireRead_(__MsgBlock, 1) < 0 || __MsgBlock[0] == 0xff) {
        0;
        SaveErrno_(-1);
        return -1;
    }
    rc = __MsgBlock[0];
    0;
    return rc;
}

/* The remaining 47 vectors follow the identical shape - pack the
   args with a per-opcode byte into __MsgBlock, WireSend/WireRead,
   check the reply.  Individual wire opcodes are documented in
   okf/functions/.  Names below follow the canonical
   bsdsocket_lib.fd ordering for v9.x. */

#define UNIMPL  __attribute__((unused)) static

LONG bind      (LONG s __asm("d0"),APTR n __asm("a0"),LONG l __asm("d1"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x4e;__MsgBlock[1]=(UBYTE)s;return (WireSend_(0x42,__MsgBlock,4)==0)?(0,0):(0,SaveErrno_(-1),-1);}
LONG listen    (LONG s __asm("d0"),LONG bk __asm("d1"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x4c;__MsgBlock[1]=(UBYTE)s;__MsgBlock[2]=(UBYTE)bk;return (WireSend_(0x42,__MsgBlock,2)==0)?(0,0):(0,SaveErrno_(-1),-1);}
LONG accept    (LONG s __asm("d0"),APTR a __asm("a0"),APTR l __asm("a1"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x41;__MsgBlock[1]=(UBYTE)s;return (WireSend_(0x42,__MsgBlock,2)==0)?(0,0):(0,SaveErrno_(-1),-1);}
LONG connect   (LONG s __asm("d0"),APTR n __asm("a0"),LONG l __asm("d1"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x4f;__MsgBlock[1]=(UBYTE)s;return (WireSend_(0x42,__MsgBlock,8)==0)?(0,0):(0,SaveErrno_(-1),-1);}
LONG sendto    (LONG s __asm("d0"),APTR m __asm("a0"),LONG l __asm("d1"),LONG f __asm("d2"),APTR to __asm("a1"),LONG tl __asm("d3"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x53;__MsgBlock[1]=(UBYTE)s;return (WireSend_(0x42,__MsgBlock,8)==0)?(0,0):(0,SaveErrno_(-1),-1);}
LONG send      (LONG s __asm("d0"),APTR m __asm("a0"),LONG l __asm("d1"),LONG f __asm("d2"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x53;__MsgBlock[1]=(UBYTE)s;return (WireSend_(0x42,__MsgBlock,8)==0)?(0,0):(0,SaveErrno_(-1),-1);}
LONG recvfrom  (LONG s __asm("d0"),APTR bf __asm("a0"),LONG l __asm("d1"),LONG f __asm("d2"),APTR fr __asm("a1"),APTR fl __asm("a2"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x46;__MsgBlock[1]=(UBYTE)s;return (WireSend_(0x42,__MsgBlock,8)==0)?(0,0):(0,SaveErrno_(-1),-1);}
LONG recv      (LONG s __asm("d0"),APTR bf __asm("a0"),LONG l __asm("d1"),LONG f __asm("d2"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x47;__MsgBlock[1]=(UBYTE)s;return (WireSend_(0x42,__MsgBlock,8)==0)?(0,0):(0,SaveErrno_(-1),-1);}
LONG shutdown  (LONG s __asm("d0"),LONG h __asm("d1"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x54;__MsgBlock[1]=(UBYTE)s;__MsgBlock[2]=(UBYTE)h;return (WireSend_(0x42,__MsgBlock,4)==0)?(0,0):(0,SaveErrno_(-1),-1);}

/* slots aliased to the shipped -1 / 0 stubs */
LONG NoImpl(void){ return -1; }      /* LIBFUNC_19 (x3) */
LONG NoOpOk(void){ return 0; }       /* LIBFUNC_31 (x3) */

/* -22 user slot 22 (LIBFUNC_22): return base+58 field */
LONG SbGetField(struct SockBase *b __asm("a6")){ return *(ULONG*)((char*)b+58); }

/* the rest are named wrappers over the same marshal skeleton;
   opcodes recorded in okf.  Simplified bodies pending deep pass. */
LONG setsockopt (LONG s __asm("d0"),LONG lv __asm("d1"),LONG op __asm("d2"),APTR v __asm("a0"),LONG l __asm("d3"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x49;return (WireSend_(0x42,__MsgBlock,8)==0)?(0,0):(0,SaveErrno_(-1),-1);}
LONG getsockopt (LONG s __asm("d0"),LONG lv __asm("d1"),LONG op __asm("d2"),APTR v __asm("a0"),APTR l __asm("a1"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x49;return 0;}
LONG getsockname(LONG s __asm("d0"),APTR n __asm("a0"),APTR l __asm("a1"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x57;return 0;}
LONG getpeername(LONG s __asm("d0"),APTR n __asm("a0"),APTR l __asm("a1"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x57;return 0;}
LONG IoctlSocket(LONG s __asm("d0"),LONG r __asm("d1"),APTR d __asm("a0"),struct SockBase *b __asm("a6")){(void)b;return 0;}
LONG CloseSocket(LONG s __asm("d0"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x2e;return (WireSend_(0x42,__MsgBlock,2)==0)?(0,0):(0,-1);}
LONG WaitSelect (LONG n __asm("d0"),APTR r __asm("a0"),APTR w __asm("a1"),APTR e __asm("a2"),APTR t __asm("a3"),ULONG m __asm("d1"),struct SockBase *b __asm("a6")){(void)b;__MsgBlock[0]=0x58;return 0;}
ULONG SetSocketSignals(ULONG i __asm("d0"),ULONG io __asm("d1"),ULONG u __asm("d2"),struct SockBase *b __asm("a6")){return 0;}
LONG getdtablesize(struct SockBase *b __asm("a6")){return 0;}
ULONG gethostid(struct SockBase *b __asm("a6")){return 0;}
LONG gethostname(APTR n __asm("a0"),LONG l __asm("d0"),struct SockBase *b __asm("a6")){return NoImpl();}
LONG getdomainname(APTR n __asm("a0"),LONG l __asm("d0"),struct SockBase *b __asm("a6")){return NoImpl();}
LONG sethostname(APTR n __asm("a0"),LONG l __asm("d0"),struct SockBase *b __asm("a6")){return NoImpl();}
LONG setdomainname(APTR n __asm("a0"),LONG l __asm("d0"),struct SockBase *b __asm("a6")){return NoOpOk();}
LONG SyslogAp(LONG lv __asm("d0"),APTR f __asm("a0"),APTR v __asm("a1"),struct SockBase *b __asm("a6")){return NoOpOk();}
LONG SetLogFunc(APTR f __asm("a0"),struct SockBase *b __asm("a6")){return 0;}
LONG Errno(struct SockBase *b __asm("a6")){return (LONG)b->sb_Errno;}
LONG SetErrnoPtr(APTR p __asm("a0"),LONG s __asm("d0"),struct SockBase *b __asm("a6")){return 0;}
STRPTR Inet_NtoA(ULONG i __asm("d0"),struct SockBase *b __asm("a6")){return NULL;}
ULONG inet_addr(APTR s __asm("a0"),struct SockBase *b __asm("a6")){return (ULONG)-1;}
LONG Inet_LtoOf(LONG s __asm("d0"),APTR l __asm("a0"),struct SockBase *b __asm("a6")){return 0;}
LONG Inet_OfToL(LONG s __asm("d0"),APTR l __asm("a0"),struct SockBase *b __asm("a6")){return 0;}
LONG Inet_MakeAddr(ULONG n __asm("d0"),ULONG h __asm("d1"),struct SockBase *b __asm("a6")){return (LONG)((n&0xff000000)|(h&0xffffff));}
ULONG inet_network(APTR s __asm("a0"),struct SockBase *b __asm("a6")){return 0;}
ULONG inet_netof(ULONG a __asm("d0"),struct SockBase *b __asm("a6")){return a>>24;}
ULONG inet_lnaof(ULONG a __asm("d0"),struct SockBase *b __asm("a6")){return a&0xffffff;}
ULONG inet_makeaddr(ULONG n __asm("d0"),ULONG h __asm("d1"),struct SockBase *b __asm("a6")){return (n<<24)|h;}
LONG Is_Localhost(ULONG a __asm("d0"),struct SockBase *b __asm("a6")){return (a>>24)==0x7f;}
LONG Dup2Socket(LONG f1 __asm("d0"),LONG f2 __asm("d1"),struct SockBase *b __asm("a6")){return f2;}
LONG ObtainSocket(LONG id __asm("d0"),LONG dm __asm("d1"),LONG tp __asm("d2"),LONG pr __asm("d3"),struct SockBase *b __asm("a6")){return id;}
LONG ReleaseSocket(LONG s __asm("d0"),LONG i __asm("d1"),struct SockBase *b __asm("a6")){return 0;}
LONG ReleaseCopyOfSocket(LONG s __asm("d0"),LONG i __asm("d1"),struct SockBase *b __asm("a6")){return 0;}

/* ---- engine + wire plumbing (LAB_00A8/00AA/00B7/00CD/00A3) ---- */
UBYTE __MsgBlock[256];
static LONG g_savedErrno;

APTR LibInit(ULONG d0 __asm("d0"), APTR seg __asm("a0"),
             struct SockBase *base __asm("a6"))
{
    (void)d0;
    base->sb_SegList = seg;
    return base;
}

static LONG WireSend_(UBYTE op __asm("d0"), UBYTE *m __asm("a0"), LONG n __asm("d1"))
{ return 0; }   /* engine-bound send; see okf - pending deep port */
static LONG WireRead_(UBYTE *m __asm("a0"), LONG n __asm("d1"))
{ return 0; }
static void SaveErrno_(LONG e) { g_savedErrno = e; }
