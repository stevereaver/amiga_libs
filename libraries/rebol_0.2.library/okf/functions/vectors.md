# rebol.library 0.2 — vectors

Absolute-longword functab at hunk+0x730, 6 entries + `0xffffffff`.
All offsets are hunk-relative.

| LVO | off   | fn     | summary |
|-----|-------|--------|---------|
| -6  | 0x06c | Open   | `addqw #1,lib+32` (OpenCnt). `_findslot` for `*(4).ThisTask`; on miss `_newslot` (Allocs a 2564-B node, links at lib+38) then `_ctxinit`: AllocMem(3896, MEMF_PUBLIC — no CLEAR), Forbid, SP := ctx-buf top, `linkw a4,#-512` (a4 = ctx), Permit, stores old-SP/sysbase/base, OpenLibrary v33 for intuition, graphics, dos; `slot.ctx=a4`. Any fail frees the ctx and decrements OpenCnt. Returns a6. |
| -12 | 0x0aa | Close  | `_findslot`; miss -> rts. `slot.count--`; on 0: detach slot, `_ctxfree` (jsr `_closecon`, jsr `_ctxzero`=rts, FreeMem ctx freelist at ctx-20, CloseLibrary x3, restore SP from ctx-4, FreeMem 3896). OpenCnt--; on 0 `bsr _expunge` — result (seglist) is returned in d0. |
| -18 | 0x0e8 | Expunge | OpenCnt!=0 -> 0 (not deferred via flag, just refused). `btst/bclr #0,lib+43` — first Expunge only clears the flag set by initfn and returns 0 (survives one expunge). Else: frees every ctx node (FreeMem 2564), `Remove(lib)`, FreeMem(lib, neg+pos), returns seglist (lib+34). |
| -24 | 0x14e | stub   | `moveq #0,d0; rts`. |
| -30 | 0x790 | RebolDo veneer | saves regs, pushes d0, `_findctx` -> a4, `bsr _reboldo`. No-ctx path runs `_reboldo` with a4=0 (wild ctx reads — see quirks). |
| -36 | 0x7a6 | RebolFreeResult veneer | same frame, `bsr _freecore`: if arg!=0 `FreeVec(arg)` via ctx-40 sysbase. Always returns 0. |

## Internal helpers

| off   | fn        | summary |
|-------|-----------|---------|
| 0x000 | romstub   | `moveq #-1,d0; rts` (ROM entry returns -1). |
| 0x04e | _initfn   | AUTOINIT init: a1=&lib+34; `bset #0,a1@(9)` (lib+43 bit0 survive-expunge flag); lib+34=seglist; lib+38=0 (ctx list); returns lib. |
| 0x152 | _findslot | walks ctx nodes from lib+38; each node: +4 next, slots at +8: {task.l @-4, ctx.l @0, count.w @4}; 255 slots/node via dbf. Returns a0=&slot.ctx or 0. |
| 0x190 | _newslot  | same walk looking for `slot.task==0`; else AllocMem(2564,CLEAR), link at lib+38 head — **NULL not checked** (writes ThisTask to $4 on OOM). |
| 0x1fe | _ctxinit  | = rt_EndSkip target. AllocMem(3896,PUBLIC); SP:=buf top under Forbid; `linkw a4,#-512`; Permit; ctx-4=old SP, -64=buf base, -40=SysBase; OpenLibrary intuition/graphics/dos v33 -> ctx-48/-52/-44; fail path frees buffer via _ctxfailN cascade. `jmp _ctxret` via abs long. Returns -1/0. |
| 0x2b0 | _ctxzero  | lone `rts` (also the target of a jsr in _ctxfree). |
| 0x2b2 | _ctxfree  | jsr _closecon (abs), jsr _ctxzero (abs), SP->ctx-4 stash, walk ctx-20 freelist FreeMem'ing each (ctx-20 never initialized), CloseLibrary ctx-44/-52/-48, restore SP from ctx-4, FreeMem 3896. |
| 0x382 | _ctxret   | bsr _minus1 (sets d2!), bsr _zero392 (d0=0), restore SP ctx-4, `moveq #-1,d0`, rts. |
| 0x392 | _zero392  | linkw/d0=0/unlk/rts. |
| 0x39c | _reboldo  | linkw a5,#-32; stack carves 4 counted buffers (cap words 1000/1200/50/100). GetVar("RebolLibCount",buf3,50,0) -> _strtol -> count (0->1 clamp, ++). _fmt "%ld" -> buf3 -> SetVar("RebolLibCount",buf3,3,0). _fmt "T:RebolLibScript.%ld" -> buf4; Open(MODE_NEWFILE); ctx-8=fh; _fputs wrapper `REBOL []\nresult: none\n%s\nif NOT none? result [write/binary %%/T/RebolLibResult.%ld result]\n` (source,count) -> FPuts; ctx-8=0; Close. GetVar("REBOL_HOME",buf1,1000,0); _fmt "%sRebol -cs %s" -> buf2; SystemTagList(buf2,0); DeleteFile(script). _fmt "T:RebolLibResult.%ld"; Open(MODE_OLDFILE); _filesize -> AllocVec(size); _filesize; _readfile(Read); Close; DeleteFile(result); returns buf. |
| 0x64e | _freecore | FreeVec(arg) if arg!=0 (through ctx-40). |
| 0x72c | _minus1   | `moveq #-1,d2` — sets **d2**, not d0 (dead helper). |
| 0x74c | _findctx  | same slot walk; returns a4 = slot.ctx or 0. |
| 0x7bc | _closecon | if ctx-12 (con fh): Read(fh,0,0) then Close; ctx-12=0. |
| 0x7de | _fmt      | `RawDoFmt(fmt=sp(8+d0), args=&sp(8), putch, ctx-64 scratch)` then copies scratch into counted dest `sp(0xc+d0)` honoring dest-4 cap; writes remaining to dest-2; returns dest. |
| 0x82e | _putch    | `moveb d0,a3@+` (scratch append). |
| 0x832 | _strtol   | skips <=32, '-' neg, '$' hex, '%' binary, else decimal (max 11 digits, 32x32->64 via mulu pairs over embedded pow10 table 0x8ae). Returns d0=value, d1=consumed, optional out at sp(20). |
| 0x9bc | _filesize | Lock(path,SHARED_LOCK=-2); Examine into a **long-aligned** on-stack FIB (btst #1,sp adjusts -260/-262); fib_Size@+124 -> d0; UnLock; -1 on any fail. |
| 0xa08 | _fsunlock2| UnLock(d7). Two bsr sites (one word, one byte). |
| 0xa1a | _fputs    | ctx-8 fh -> RawDoFmt into ctx-64 scratch, FPuts(fh,scratch), returns strlen. ctx-8==0: Open("CON:0/11/640/80/Output",NEWFILE) -> ctx-12/-8; on fail sets ctx-28=20 then `jmp *(ctx-24)` — **ctx-24 is never initialized** (wild jump). |
| 0xaa2 | _readfile | d2 = size * sp@(8) via dbf add-loop (always x1 — sp@(8) is pushed 1); Read(fh,buf,size); counts Read-chunks; returns count. |

## Strings (0x278-0x2ac, 0x30c-0x381, 0x66c-0x72b, 0xa8a)

- `dos.library`, `intuition.library`, `graphics.library` inside _ctxinit.
- `rebol.library` @0x30c; idstring @0x31a (missing `)` before `/©`).
- `T:RebolLibResult.%ld`, `%sRebol -cs %s`, `REBOL_HOME`,
  the `REBOL []` wrapper, `T:RebolLibScript.%ld`, `%ld`,
  `RebolLibCount` (x2), `CON:0/11/640/80/Output`.

## System vectors used

Exec: -132 Forbid, -138 Permit, -198 AllocMem, -210 FreeMem,
-252 Remove, -414 CloseLibrary, -522 RawDoFmt, -552 OpenLibrary,
-684 AllocVec, -690 FreeVec. `ThisTask` read directly from
SysBase+276 (`moveal 4:w,a1; movel a1@(276),d0`).

DOS: -30 Open, -36 Close, -42 Read, -72 DeleteFile, -84 Lock,
-90 UnLock, -102 Examine, -342 FPuts, -606 SystemTagList,
-900 SetVar, -906 GetVar.
