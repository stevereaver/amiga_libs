# config.library — vectors

Function table is 8 absolute-long entries at h1+0x128 (in the DATA
hunk), terminated by 0xffffffff.  Entry points are h0-relative code
offsets.  All public functions take register args (SAS/C style) and
reload `a4 = h1+0x7ffe` (small-data base) on entry.

| LVO | h0 off | fn       | signature / semantics |
|-----|--------|----------|------------------------|
| -6  | 0x738  | `_open`     | `a6=lib -> a6` : `lib_OpenCnt(+0x20)++`, clears `lib_Flags(+0xe)` bit 3 (`LIBF_DELEXP`, `andib #0xf7`), returns lib base. |
| -12 | 0x750  | `_close`    | `a6=lib -> seglist|0` : `OpenCnt--`; if it hits 0 **and** `LIBF_DELEXP` is set, falls into `_expunge` and returns its seglist result (deferred expunge); else returns 0. |
| -18 | 0x778  | `_expunge`  | `a6=lib -> seglist|0` : if `OpenCnt != 0` sets `LIBF_DELEXP` (bit 3 of +0xe) and returns 0. Else `a2 = lib+0x22` (seglist), `exec Remove(lib)`, `closedeps()` (CloseLibrary of gfx/int/dos cells, skipping NULLs — note it does **not** clear the cells), then `FreeMem(lib - NegSize, NegSize + PosSize)`. Returns seglist (h0 base). |
| -24 | 0x7da  | `_nullv`    | `-> 0` (`moveq #0,d0; rts` under the a4-reload prologue). |
| -30 | 0x000  | `SetStr`    | `d0=file, d1=section, d2=key, d3=value -> d0=1|0`. Slurps the whole file into a `MinList` of AllocVec'd, newline-stripped lines (FGets 255 into a 274-byte stack buffer). Reopens the file with `MODE_NEWFILE(1006)` — whole file rewritten in place. Per node: `[...]` headers echoed via `"%s%s\n"` with a `d6 ? "\n" : ""` separator (blank line before every header except the first line); on entering a header while `d5`(in-target-section) is set and `d4`(key-written) is clear it first emits `key = value` (pending insert at section end); a stored line that matches `strnicmp(line,key,len)` **and** `strnicmp(line+len," = ",3)` is replaced with `"%s = %s\n" (key,value)`; all other lines echoed via `"%s\n"`. After the loop: still in target section with unwritten key -> append `"key = value\n"`; section never seen -> emit `"%s[%s]\n"(sep,section)` then `"%s = %s\n"(key,value)`. Failures: unreadable+uncreatable file, AllocVec fail, or node-add fail -> 0 (list freed). Always 1 on the write path — VFPrintf results are ignored. |
| -36 | 0x2a0  | `SetNum`    | `d0=file, d1=section, d2=key, d3=long -> d0`. `sprintf(stackbuf, "%ld", d3)` (RawDoFmt via `moveal 4,a6`) then tail-calls `SetStr(file, section, key, buf)`. |
| -42 | 0x2de  | `GetStr`    | `d0=file, d1=section, d2=key, d3=buf, d4=bufsize, d5=default -> d0=1|0`. Opens `MODE_OLDFILE(1005)`; per line (FGets 256 into 256-byte stack buf) strips `line[strlen-1]` unconditionally. Tracks section with `line[0]=='[' && line[strlen-1]==']' && strnicmp(line+1, section, strlen(section))==0` (case-insensitive, **prefix** match only). In the target section a line hits when `strnicmp(line,key,len)`==0 and `strnicmp(line+len," = ",3)`==0; the value is `line+len+3`. `strlen(value) >= bufsize` -> Close, return **0** (nothing copied). EOF/miss/missing file -> `strcpy(buf, default)`, return **1** — unless `strlen(default) >= bufsize` -> 0. |
| -48 | 0x47c  | `GetNum`    | `d0=file, d1=section, d2=key, d3=default_long -> d0=value`. Formats `default` into a 20-byte buffer via `sprintf("%ld")`, calls `GetStr(file, section, key, out=a5@-40, bufsize=20, default=that)`, then `dos.StrToLong(out, &cell)` and **returns the cell regardless of StrToLong's result** — an unparseable value yields whatever garbage was in the stack slot (oracle: `getnum-bad` returned the previous call's 1234). Defaults work because the formatted default is fed back through the parser. |

## initfn (InitTable+0xc, h0+0x6fc)

`d0=libbase, a0=seglist, a6=SysBase`. Stores lib into the small-data
cell `h1+0x14c`, writes `lib+0x22 = seglist`, `lib+0x26 = SysBase`,
calls `opendeps` (h0+0x628): caches `SysBase` at `h1+0x4c`, then
`OpenLibrary(name, 37)` into cells `h1+0x50` (dos), `h1+0x54`
(intuition), `h1+0x58` (graphics) **in that order**, copying them to
`lib+0x2a/0x2e/0x32`; any failure -> `closedeps` + return 0. Success
returns the lib base.

## Support routines (h0)

| off   | fn         | notes |
|-------|------------|-------|
| 0x4d4 | `_listinit`| NewList-style init of caller's list header |
| 0x4f4 | `_listadd` | AllocVec(14,MEMF_CLEAR) node {succ,pred,type,pri,name}, AddTail |
| 0x536 | `_listfree`| RemHead + FreeVec each node, then frees the line buffer |
| 0x56a | `_strlen`  | |
| 0x57e | `_strcpy`  | |
| 0x5a4 | `_strnicmp`| case-insensitive compare, len as arg |
| 0x628 | `_opendeps`| see initfn |
| 0x6ae | `_closedeps`| CloseLibrary on h1+0x58/0x54/0x50 (gfx,int,dos) |
| 0x6ec | `_null0`   | dead second null stub (not in functab) |
| 0x6fc | `_initfn`  | see above |
| 0x7e8 | `_dos_Close`    | `a1` arg, `jsr a6@(-36)`  via DOS cell h1+0x50 |
| 0x7fc | `_dos_FGets`    | `d1/d2/d3` args, `jsr a6@(-336)` |
| 0x818 | `_dos_VFPrintf` | `d1/d2/d3` args, `jsr a6@(-354)` |
| 0x838 | `_dos_Open`     | `d1/d2` args, `jsr a6@(-30)` |
| 0x854 | `_dos_StrToLong`| `d1/d2` args, `jsr a6@(-816)` |
| 0x870 | `_ex_AddTail`   | `a0/a1` args, `jsr a6@(-246)` via exec cell h1+0x4c |
| 0x888 | `_ex_AllocVec`  | `d0/d1` args, `jsr a6@(-684)` |
| 0x8a0 | `_ex_CloseLibrary` | `a1`, `jsr a6@(-414)` |
| 0x8b4 | `_ex_FreeMem`   | `a1/d0`, `jsr a6@(-210)` |
| 0x8cc | `_ex_FreeVec`   | `a1`, `jsr a6@(-690)` |
| 0x8e0 | `_ex_OpenLibrary` | `a1/d0`, `jsr a6@(-552)` |
| 0x8f8 | `_ex_RemHead`   | `a0`, `jsr a6@(-258)` |
| 0x90c | `_ex_Remove`    | `a1`, `jsr a6@(-252)` |
| 0x920 | `_sprintf`      | stack-arg varargs -> `moveal 4,a6; jsr a6@(-522)` (RawDoFmt) with `_putch` (0x944) writing `(a3)+` |
| 0x948..0x962 | `_r0a.._rtse` | register-save/restore stubs (`movem` shims), tail padding |

All `_ex_*`/`_dos_*` wrappers load their base from the small-data cell
(`a4@(-32690)` = exec, `a4@(-32686)` = dos) — SAS/C LVO-call shim form.
