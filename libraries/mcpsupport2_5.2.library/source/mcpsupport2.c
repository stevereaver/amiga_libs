/*
**	mcpsupport2.c -- mcpsupport2.library 5.2
**	(c)1995-1998 by ALiENDESiGN
**
**	C reconstruction of the shipped SAS/C-style binary
**	(14.10.98).  A helper library for an "MCP"-style tool:
**
**	  -30 mcpLoadFile(flags@d0, name@d1)
**		Lock+Examine the file for its size, AllocVec
**		size+1 bytes, Open+Read it, Close+UnLock.
**		Returns the buffer in d0 and the size in d1
**		(0/0 on any failure); NUL-terminates at [size].
**
**	  -36 mcpCmdNameBuf(flags@d0, len@d1, task@a0, dest@a1)
**		Walk task->pr_CLI->cli_CommandName to a BSTR;
**		if flags&1 strip to the basename (after the
**		last '/' or ':'); copy into dest[len].  Returns
**		dest or the found pointer.
**
**	  -42 mcpCmdName(flags@d0, task@a0)
**		Same walk; returns the BSTR/its basename ptr.
**
**	  -48 mcpMatch(pat@d0, str@d1)
**		AmigaDOS wildcard matcher (~,(),|) using
**		utility.library's ToUpper.
**
**	The library has dataSize 0x22 (plain struct Library);
**	INIT allocates a 12-byte aux block holding
**	{seglist, dosbase, utilitybase} referenced as auxblock.
**
**	Shipped behaviour kept: the $VER string says "5.0" but
**	the InitStruct revision is 2 (the lib reports 5.2).
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/tasks.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <dos/dosextens.h>

/* ------------------------------------------------------------------ */
/* aux block + sysbase						  */
/* ------------------------------------------------------------------ */

extern ULONG auxblock[3];	/* {seglist, doslib, utilitybase} */
#define SYSBASE	(*(struct ExecBase **)4)
#define DOSBASE	((struct DosLibrary *)auxblock[1])
#define UTILBASE ((struct Library *)auxblock[2])

/* ------------------------------------------------------------------ */
/* exec calls							  */
/* ------------------------------------------------------------------ */

#define __AllocMem(__size, ___flags) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_d0 __asm("d0") = (ULONG)(__size);\
  register ULONG __p_d1 __asm("d1") = (ULONG)(___flags);\
  __asm volatile ("jsr %/a6@(-198:W)\n"\
		   : "+d"(__p_d0)\
		   : "d"(__p_d1), "a"(__p_sys)\
		   : "cc", "memory", "a0", "a1" );\
  (APTR)__p_d0;})

#define __FreeMem(__blk, ___size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  register ULONG __p_d0 __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "d"(__p_d0), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

#define __AllocVec(__size, ___flags) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register ULONG __p_d0 __asm("d0") = (ULONG)(__size);\
  register ULONG __p_d1 __asm("d1") = (ULONG)(___flags);\
  __asm volatile ("jsr %/a6@(-684:W)\n"\
		   : "+d"(__p_d0)\
		   : "d"(__p_d1), "a"(__p_sys)\
		   : "cc", "memory", "a0", "a1" );\
  (APTR)__p_d0;})

#define __FreeVec(__blk) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  __asm volatile ("jsr %/a6@(-690:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "a"(__p_sys)\
		   : "cc", "memory", "d0","d1","a0" );})

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __Forbid() ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  __asm volatile ("jsr %/a6@(-132:W)\n"\
		   : /* no outputs */ : "a"(__p_sys)\
		   : "cc", "memory", "d0","d1","a0","a1" );})

#define __Permit() ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  __asm volatile ("jsr %/a6@(-138:W)\n"\
		   : /* no outputs */ : "a"(__p_sys)\
		   : "cc", "memory", "d0","d1","a0","a1" );})

#define __FindTask(__name) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_name __asm("a1") = (APTR)(__name);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-294:W)\n"\
		   : "=r"(__p_res)\
		   : "a"(__p_name), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );\
  __p_res;})

#define __CloseLibrary(__sys, ___lib) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register APTR __p_lib __asm("a1") = (APTR)(___lib);\
  __asm volatile ("jsr %/a6@(-414:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_lib), "a"(__p_sys)\
		   : "cc", "memory", "d0","d1","a0" );})

/* ------------------------------------------------------------------ */
/* dos calls (through the opened dos base)			  */
/* ------------------------------------------------------------------ */

#define __Open(___name, ___mode) ({\
  register void * __p_dos __asm("a6") = DOSBASE;\
  register const char * __p_name __asm("d1") = (___name);\
  register ULONG __p_d2 __asm("d2") = (ULONG)(___mode);\
  register ULONG __p_d0 __asm("d0");\
  __asm volatile ("jsr %/a6@(-30:W)\n"\
		   : "=d"(__p_d0)\
		   : "d"(__p_name), "d"(__p_d2), "a"(__p_dos)\
		   : "cc", "memory", "a0","a1" );\
  __p_d0;})

#define __Close(__fh) ({\
  register void * __p_dos __asm("a6") = DOSBASE;\
  register BPTR __p_fh __asm("d1") = (__fh);\
  __asm volatile ("jsr %/a6@(-36:W)\n"\
		   : /* no outputs */\
		   : "d"(__p_fh), "a"(__p_dos)\
		   : "cc", "memory", "d0","a0","a1" );})

#define __Read(__fh, ___buf, ___len) ({\
  register void * __p_dos __asm("a6") = DOSBASE;\
  register BPTR __p_fh __asm("d1") = (__fh);\
  register APTR __p_buf __asm("d2") = (APTR)(___buf);\
  register ULONG __p_len __asm("d3") = (ULONG)(___len);\
  register ULONG __p_d0 __asm("d0");\
  __asm volatile ("jsr %/a6@(-42:W)\n"\
		   : "=d"(__p_d0)\
		   : "d"(__p_fh), "d"(__p_buf), "d"(__p_len), "a"(__p_dos)\
		   : "cc", "memory", "a0","a1" );\
  __p_d0;})

#define __Lock(___name, ___mode) ({\
  register void * __p_dos __asm("a6") = DOSBASE;\
  register const char * __p_name __asm("d1") = (___name);\
  register ULONG __p_d2 __asm("d2") = (ULONG)(___mode);\
  register ULONG __p_d0 __asm("d0");\
  __asm volatile ("jsr %/a6@(-84:W)\n"\
		   : "=d"(__p_d0)\
		   : "d"(__p_name), "d"(__p_d2), "a"(__p_dos)\
		   : "cc", "memory", "a0","a1" );\
  __p_d0;})

#define __UnLock(__lock) ({\
  register void * __p_dos __asm("a6") = DOSBASE;\
  register BPTR __p_lock __asm("d1") = (__lock);\
  __asm volatile ("jsr %/a6@(-90:W)\n"\
		   : /* no outputs */\
		   : "d"(__p_lock), "a"(__p_dos)\
		   : "cc", "memory", "d0","a0","a1" );})

#define __Examine(__lock, ___fib) ({\
  register void * __p_dos __asm("a6") = DOSBASE;\
  register BPTR __p_lock __asm("d1") = (__lock);\
  register void * __p_fib __asm("d2") = (___fib);\
  register ULONG __p_d0 __asm("d0");\
  __asm volatile ("jsr %/a6@(-102:W)\n"\
		   : "=d"(__p_d0)\
		   : "d"(__p_lock), "d"(__p_fib), "a"(__p_dos)\
		   : "cc", "memory", "a0","a1" );\
  __p_d0;})

#define __AllocDosObject(__type, ___tags) ({\
  register void * __p_dos __asm("a6") = DOSBASE;\
  register ULONG __p_d1 __asm("d1") = (ULONG)(__type);\
  register ULONG __p_d2 __asm("d2") = (ULONG)(___tags);\
  register ULONG __p_d0 __asm("d0");\
  __asm volatile ("jsr %/a6@(-228:W)\n"\
		   : "=d"(__p_d0)\
		   : "d"(__p_d1), "d"(__p_d2), "a"(__p_dos)\
		   : "cc", "memory", "a0","a1" );\
  __p_d0;})

#define __FreeDosObject(__type, ___obj) ({\
  register void * __p_dos __asm("a6") = DOSBASE;\
  register ULONG __p_d1 __asm("d1") = (ULONG)(__type);\
  register APTR __p_obj __asm("d2") = (APTR)(___obj);\
  __asm volatile ("jsr %/a6@(-234:W)\n"\
		   : /* no outputs */\
		   : "d"(__p_d1), "d"(__p_obj), "a"(__p_dos)\
		   : "cc", "memory", "d0","a0","a1" );})

/* utility ToUpper @ -174					 */
#define __ToUpper(__ch) ({\
  register void * __p_ut __asm("a6") = UTILBASE;\
  register ULONG __p_d0 __asm("d0") = (ULONG)(__ch);\
  __asm volatile ("jsr %/a6@(-174:W)\n"\
		   : "+d"(__p_d0)\
		   : "a"(__p_ut)\
		   : "cc", "memory", "a0","a1" );\
  (UBYTE)__p_d0;})

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

struct Library *LibOpen(struct Library *base __asm("a6"))
{
    base->lib_OpenCnt++;
    base->lib_Flags &= ~LIBF_DELEXP;
    return base;
}

BPTR LibExpunge(struct Library *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->lib_OpenCnt) {
	base->lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = (BPTR)auxblock[0];
    __CloseLibrary(sys, (struct Library *)auxblock[1]);
    __CloseLibrary(sys, (struct Library *)auxblock[2]);
    __Remove(sys, &base->lib_Node);
    __FreeMem((UBYTE *)base - base->lib_NegSize,
	      (ULONG)base->lib_NegSize + base->lib_PosSize);
    __FreeMem(auxblock, 12);

    return seg;
}

LONG LibClose(struct Library *base __asm("a6"))
{
    if (--base->lib_OpenCnt == 0) {
	if (base->lib_Flags & LIBF_DELEXP)
	    return (LONG)LibExpunge(base);
    }
    return 0;
}

/* ------------------------------------------------------------------ */
/* -30 mcpLoadFile: read a whole file into an AllocVec'd buffer	  */
/* ------------------------------------------------------------------ */

/* returns buffer in d0 and size in d1 (both zero on failure) */
APTR mcpLoadFile(ULONG flags __asm("d0"), const char *name __asm("d1"))
{
    BPTR   lock;
    APTR   fib;
    ULONG  size = 0;
    APTR   buf = 0;
    BPTR   fh;
    ULONG  nread;

    lock = (BPTR)__Lock(name, ACCESS_READ);		/* -84 */
    if (!lock)
	goto out;
    fib = (APTR)__AllocDosObject(2, 0);			/* -228 DOS_FIB */
    if (!fib)
	goto out;
    if (__Examine(lock, fib))				/* -102 */
	size = ((struct FileInfoBlock *)fib)->fib_Size;
    __FreeDosObject(2, fib);				/* -234 */
    if (!size)
	goto out;
    buf = __AllocVec(size + 1, flags);			/* -684 */
    if (!buf)
	goto out;
    fh = (BPTR)__Open(name, MODE_OLDFILE);		/* -30 */
    if (!fh) {
	__FreeVec(buf);					/* -690 */
	goto out;
    }
    nread = __Read(fh, buf, size);			/* -42 */
    ((UBYTE *)buf)[size] = 0;				/* SF -> term */
    __Close(fh);					/* -36 */
    if (nread != size) {
	__FreeVec(buf);
	goto out;
    }
    __UnLock(lock);					/* -90 */
    {
	register ULONG _size __asm("d1") = size;
	__asm volatile ("" : "+d"(_size));	/* keep size in d1 */
	return buf;
    }
out:
    if (lock)
	__UnLock(lock);
    {
	register ULONG _zero __asm("d1") = 0;
	__asm volatile ("" : "+d"(_zero));
	return 0;
    }
}

/* ------------------------------------------------------------------ */
/* -36/-42 command-name helpers					  */
/* ------------------------------------------------------------------ */

/* walk task->pr_CLI->cli_CommandName; returns the BSTR		*/
static BSTR cmdname_walk(struct Task *t)
{
    struct Process *p = (struct Process *)t;
    UBYTE  *cli;
    UBYTE  *bstr;

    if (!p)
	p = (struct Process *)__FindTask(NULL);
    if (!p)
	return 0;
    /* ln_Type must be NT_PROCESS (0x0d)		      */
    if (((struct Node *)p)->ln_Type != 0x0d)
	return 0;
    cli = (UBYTE *)((ULONG)p->pr_CLI << 2);		/* bcpl -> ptr */
    if (!cli)
	return 0;
    bstr = (UBYTE *)((ULONG)((struct CommandLineInterface *)cli)
		     ->cli_CommandName << 2);		/* bcpl BSTR */
    if (!bstr || !*bstr)
	return 0;
    {
	/* validate the BSTR: its length byte must equal the
	 * number of following bytes			      */
	UBYTE *s = bstr + 1;
	BYTE   n = -1;
	while (*s)
	    n++, s++;
	if (*bstr != (UBYTE)n)
	    return 0;
    }
    return (BSTR)bstr;
}

/* strip to basename: advance past the last '/' or ':'	*/
static UBYTE *basename(UBYTE *s, ULONG flags)
{
    if (!(flags & 1))
	return s;
    {
	UBYTE *p = s;
	while (*p) {
	    if (*p == '/' || *p == ':')
		s = p + 1;
	    p++;
	}
    }
    return s;
}

/* -36 mcpCmdNameBuf: copy the command name into dest[len]	*/
APTR mcpCmdNameBuf(ULONG flags __asm("d0"), ULONG len __asm("d1"),
		   struct Task *task __asm("a0"), UBYTE *dest __asm("a1"))
{
    BSTR   found;
    UBYTE *src;

    __Forbid();
    found = cmdname_walk(task);
    if (found) {
	src = basename((UBYTE *)found + 1, flags);		/* +1 past len */
	{
	    UBYTE *d = dest;
	    ULONG  n = len;
	    if (n) {
		--n;
		while ((*d++ = *src++) != 0) {
		    if (--n == 0)
			break;
		}
	    }
	}
    }
    __Permit();
    return dest;
}

/* -42 mcpCmdName: return the command-name pointer		*/
APTR mcpCmdName(ULONG flags __asm("d0"), struct Task *task __asm("a0"))
{
    BSTR   found;
    UBYTE *res = 0;

    __Forbid();
    found = cmdname_walk(task);
    if (found)
	res = basename((UBYTE *)found + 1, flags);
    __Permit();
    return res;
}

/* ------------------------------------------------------------------ */
/* -48 mcpMatch: AmigaDOS wildcard pattern matcher		  */
/* ------------------------------------------------------------------ */

/* Recursive AmigaDOS wildcard matcher.
 * Tokens: '?' any char, '#' repeat-next-token (0+),
 * '('..'|'..')' alternation, '~' negate.
 * m_seq matches a token run until '|',')' or NUL and
 * advances both cursors; greedy, first-match-wins -- mirrors
 * the original's non-backtracking matcher.		   */
static LONG m_seq(UBYTE **pp, UBYTE **sp);

/* consume one instance of the token at tok, advancing *sp.
 * token = '?' or a literal char (case-insensitive).	   */
static LONG m_tok1(UBYTE *tok, UBYTE **sp)
{
    UBYTE c = *tok;
    UBYTE s = **sp;
    if (c == '?') {
	if (!s)
	    return 0;
	(*sp)++;
	return 1;
    }
    if (s && __ToUpper(c) == __ToUpper(s)) {
	(*sp)++;
	return 1;
    }
    return 0;
}

static LONG m_seq(UBYTE **pp, UBYTE **sp)
{
    for (;;) {
	UBYTE c = **pp;
	if (!c || c == '|' || c == ')')
	    return 1;			/* run matched		    */
	if (c == '#') {
	    UBYTE *tok = *pp + 1;
	    UBYTE *rest;
	    if (!*tok) { (*pp)++; continue; }
	    rest = tok + 1;		/* token = 1 char	    */
	    /* zero-or-more: try the remainder at each position	*/
	    for (;;) {
		UBYTE *p2 = rest, *s2 = *sp;
		if (m_seq(&p2, &s2) && !*s2) {
		    *pp = p2; *sp = s2;
		    return 1;
		}
		if (!m_tok1(tok, sp))
		    return 0;
	    }
	}
	if (c == '?') {			/* any single char	*/
	    if (!**sp)
		return 0;
	    (*pp)++;
	    (*sp)++;
	    continue;
	}
	if (c == '~') {			/* negation: full-match	*/
	    UBYTE *p2, *s2;
	    (*pp)++;
	    p2 = *pp; s2 = *sp;
	    if (!(m_seq(&p2, &s2) && !*s2)) {
		/* inner did NOT match -> negation succeeds:
		 * consume the rest of the string		    */
		while (**sp)
		    (*sp)++;
		return 1;
	    }
	    return 0;
	}
	if (c == '(') {
	    UBYTE *p = *pp + 1;
	    for (;;) {
		UBYTE *p2 = p, *s2 = *sp;
		if (m_seq(&p2, &s2)) {
		    /* alternative matched: skip to ')'	    */
		    while (*p2 && *p2 != ')')
			p2++;
		    *pp = (*p2 == ')') ? p2 + 1 : p2;
		    *sp = s2;
		    goto next;
		}
		while (*p && *p != '|' && *p != ')')
		    p++;
		if (*p == '|') { p++; continue; }
		return 0;
	    }
	}
	/* literal char (case-insensitive)			    */
	if (!**sp || __ToUpper(c) != __ToUpper(**sp))
	    return 0;
	(*pp)++;
	(*sp)++;
    next:;
    }
}

LONG mcpMatch(UBYTE *pat __asm("d0"), UBYTE *str __asm("d1"))
{
    UBYTE *p = pat, *s = str;
    LONG   r = m_seq(&p, &s);
    return (r && !*s) ? 1 : 0;
}
