# rexxsupport.library 34.9 — vectors & ARexx commands

## Library vectors

| LVO | Addr  | Entry | Behavior |
|-----|-------|-------|----------|
| -6  | +0x80 | LibOpen | `bclr #3,flags@14` (DELEXP), `opencnt@32++`, return a6 |
| -12 | +0x8e | LibClose | `opencnt--`; if 0 and DELEXP → re-set DELEXP, retest, fall into Expunge; else d0=0 |
| -18 | +0x9c | LibExpunge | set DELEXP; `opencnt>0` → d0=0 (deferred); else Remove(lib node), CloseLibrary(rexxsyslib), FreeMem(lib-NegSize, Neg+Pos), return seglist |
| -24 | +0xda | null | `moveq #0,d0; rts` (shared exit for failed Close/Expunge too) |
| -30 | +0xde | dispatch | command-table lookup, arg conversion, call, result packaging |

## initfn (+0x5e)

Called by the hunk loader's resident init with d0=lib base,
a0=seglist, a6=SysBase.  Stores SysBase@34 and seglist@42,
`OpenLibrary("rexxsyslib.library", 36)` → @38.  Returns lib
base, or 0 if rexxsyslib is missing/too old (whole init fails,
library is not added).

## Dispatcher (-30, +0xde)

Entry: `a0` = request block, `a6` = library base.

- `a5` = request block; `a2` = `a5+20` (task block);
  `a4` = libbase+38 → RexxSysBase; `d4` = ExecBase (from
  `a4+36`); `a3` = `*(a2+136)` (raw result buffer).
- `d7` = `a5+31` (argcount excluding the name);
  `a0` = `a5+44` (arg0 argstring), `a1` = `a5+48` (arg1),
  `a5+52` = arg2, `a5+56` = arg3.
- `d3` = converted numeric value of the last *flagged* arg
  (per-record `argflags` bitmask selects which args pass
  through rexxsyslib -474; conversion failure → err18).
- Name lookup scans a packed record table: names must be
  4–9 chars; matching is case-insensitive.  Miss → `d0=1`
  (a0 left pointing into the command table — see quirks).
- Argcount outside record `[min,max]` → `d0=17`.
- Handler is called via the 24-word jump table `jtab`.
- Result packaging by flag bits the handler sets in `d7`:
  bit31 raw — CreateArgstring(-126) of `a3`/`d3` bytes;
  bit16 numeric — value→argstring (-312) of `d3`;
  bit17 bool — `d3` selects rl_FALSE/rl_TRUE (`a4+68/72`, +8);
  bit18 empty — rl_NULL (`a4+64`, +8).  No bits → `a0` returned
  as-is (handlers that already built an argstring).
- Packaging failure → `d0=3`; success → `d0=0`, `a0`=result
  argstring; the d0 codes 1/17/18/3 map to ARexx error levels.

## Command table (+0x264)

Packed records `[cksum][name][max<<4|min][argflags]` — sections
for each name length *overlap* (the trailing bytes of a len-N
record can be read as the leading bytes of a len-N+1 record);
the last record's trailer is `jtab[0]`'s high byte.
`argflags` = bitmask of args numerically converted up front
(bit i → arg i; converted value in `d3`).

| # | Name | min–max | argflags | Handler | Semantics |
|---|------|---------|----------|---------|-----------|
| 1 | NEXT    | 1–2 | 0x02 | +0x56e | `*(*(arg0)+arg1)` — dereference token ptr + numeric offset; odd effective addr → err18. 4-byte raw |
| 2 | NULL    | 0–0 | 0x00 | +0x55e | write 4 zeros to result buf → raw `\x00\x00\x00\x00` |
| 3 | BADDR   | 1–1 | 0x00 | +0x562 | `*(arg0) << 2` — BCPL→C pointer. 4-byte raw |
| 4 | DELAY   | 1–1 | 0x01 | +0x4fe | dos Delay(arg0 ticks) → bool |
| 5 | REPLY   | 1–3 | 0x02 | +0x6d0 | reply a queued packet: Result1=arg1; Result2=argstring(arg2) only when rc==0 && pkt+29 bit1 && argcount≥3; Remove+ReplyMsg → bool TRUE |
| 6 | DELETE  | 1–1 | 0x00 | +0x512 | dos DeleteFile(arg0) → bool |
| 7 | FORBID  | 0–0 | 0x00 | +0x542 | exec Forbid → numeric TDNestCnt (typically 1) |
| 8 | GETARG  | 2–2 | 0x02 | +0x758 | packet arg: class must be 1 or 2 (`pkt+28` high byte); `pkt+40+idx*4` argstring → raw copy; missing/null arg → empty; bad class → err18 |
| 9 | GETPKT  | 1–1 | 0x00 | +0x5ca | find port node by name; GetMsg(embedded port); AddTail to pending list; returns 4-byte msg token (0 if none); unknown port → err18 |
| 10 | OFFSET | 2–2 | 0x00 | +0x580 | `*(arg0)+value(arg1)` — pointer arithmetic, no deref. 4-byte raw |
| 11 | PERMIT | 0–0 | 0x00 | +0x54a | exec Permit → numeric TDNestCnt (typically 0) |
| 12 | RENAME | 2–2 | 0x00 | +0x594 | dos Rename(arg0→arg1) → bool |
| 13 | STATEF | 1–1 | 0x00 | +0x36a | Lock+Examine+UnLock → formatted `"DIR\|FILE <sz> <blk> <prot> <d> <m> <t> <cmt>"`; lock/Examine fail → empty |
| 14 | FORWARD| 2–2 | 0x00 | +0x6a6 | Forbid; FindPort(arg1); if found: Remove(msg); PutMsg(**d2!**,msg) — see defects; Permit → bool(port-found) |
| 15 | FREEMEM| 2–2 | 0x02 | +0x642 | FreeMem(*(arg0), arg1); token len≠4 / size 0 / ptr 0 → err18; else bool TRUE |
| 16 | MAKEDIR| 1–1 | 0x00 | +0x51a | CreateDir(arg0) → UnLock(lock) → bool |
| 17 | SHOWDIR| 1–3 | 0x00 | +0x43a | Lock+Examine dir → flatten ExNext names via rxs stub list → argstring; arg1 'D'/'F' filter, arg2 separator; non-dir/fail → empty |
| 18 | TYPEPKT| 1–2 | 0x00 | +0x600 | pkt+28 action long: no arg1 → raw 4 bytes; 'A' → numeric **low byte** (argc, quirk); 'C'/'F' → bool class==1/class==2; other → err18 |
| 19 | WAITPKT| 1–1 | 0x00 | +0x71e | find port node; queued msg → TRUE; else Wait(caller-bit\|port-bit), bool = port signal arrived; unknown → err18 |
| 20 | ALLOCMEM|1–2 | 0x01 | +0x59a | AllocMem(size=arg0, flags: arg1 4-byte token, default 1=MEMF_PUBLIC) → 4-byte raw ptr; size 0 → err18; fail → err3 |
| 21 | OPENPORT|1–1 | 0x00 | +0x65c | Forbid; FindPort(arg0); absent → rxs-198 create node; Permit; bool = rxs-198 d0≠0 — **FALSE when the port already exists** (stale d3, quirk) |
| 22 | SHOWLIST|1–4 | 0x00 | +0x798 | dump lists — see below |
| 23 | CLOSEPORT|1–1 | 0x00 | +0x686 | rxs-180 find port node → rxs-204 close → bool(found) |

## SHOWLIST (+0x798)

Builds a 14-byte stub MinList on the stack (rxs-222 init),
selects a source by first char of arg0 (uppercased):

| sel | source | mode |
|-----|--------|------|
| 'A' | DOS device nodes, dl_Type==1 (assigns) | devscan |
| 'D' | SysBase+350 DeviceList | exec list |
| 'H' | DOS device nodes, dl_Type==0 (handlers) | devscan |
| 'I' | SysBase+364 IntrList | exec list |
| 'L' | SysBase+378 LibList | exec list |
| 'M' | SysBase+322 MemList | exec list |
| 'P' | SysBase+392 PortList | exec list |
| 'R' | SysBase+336 ResourceList | exec list |
| 'S' | SysBase+532 SemaphoreList | exec list |
| 'T' | SysBase+406 TaskReady (d2=-1 → type -1) | exec list |
| 'V' | DOS device nodes, dl_Type==2 (volumes) | devscan |
| 'W' | SysBase+420 TaskWait | exec list |
| '@' | `'@'+4-byte binary address +1 byte` — literal list pointer; address must be even and `*(list+4)==0` | raw list |
| other | → err18 | |

Devscan (A/H/V) Forbids, walks `DOSBase+34 → dl_Root → +24
rn_Info (BPTR) → +4 di_DevList` BPTR chain, appends each
matching node's BSTR name (+40) uppercased into the stub, then
Permits; node+24 is set to the real devnode.

argcount ≥2 → FindName(stub-or-list, arg1): ≥4 args requires
arg3=='A' (else err18) and returns the node (+24 object for
devscan finds) as a raw 4-byte token; <4 args → bool(found).
argcount 1 → flatten all names (rxs-210) with separator arg2
(default space) → argstring.
