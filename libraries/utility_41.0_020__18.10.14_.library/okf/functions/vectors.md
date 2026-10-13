# utility 41.0 (020) — vector map

Entry offsets are code-hunk relative.  Args follow the register
conventions of utility.library (d0/d1/a0/a1/a2 inputs, d0 result).

## Lifecycle

| LVO | entry | notes |
|-----|-------|-------|
| -6   | 0x120 | Open: `addqw #1,lib+32`, returns lib |
| -12  | 0x274 | Close: `subqw #1,lib+32`, returns 0 — never expunges |
| -18  | 0x278 | Expunge: `moveq #0,d0; rts` — never removes |
| -24  | 0x278 | reserved stub (same `moveq#0;rts`) |

## Tag items

| LVO | entry | notes |
|-----|-------|-------|
| -30  | 0x2e8 | FindTagItem(tag=d0,list=a0) — shared internal entry |
| -36  | 0x326 | GetTagData(tag=d0,def=d1,list=a0) |
| -42  | 0x202 | PackBoolTags(flags=d0,list=a0,map=a1): ti_Data? `flags|=map` : `flags&=~map`; map default 0 |
| -48  | 0x1d2 | NextTagItem(pp=a0): END→0, IGNORE→skip, MORE→chain (null→end), SKIP→skip 1+ti_Data items, else return item |
| -54  | 0x27c | FilterTagChanges(chg=a0,old=a1,apply=d0): equal data → change item tag=IGNORE; different → `apply? olditem->data=new : keep` |
| -60  | 0x2b4 | MapTags(list=a0,map=a1,type=d0): found → item->tag=map->data; not found → `type? keep : tag=IGNORE` |
| -66  | 0x15c | AllocateTagItems(n=d0): AllocVec(n*8, MEMF_CLEAR\|PUBLIC) |
| -72  | 0x19e | CloneTagItems(a0): Forbid, counts n+1 (includes the null call), allocs (n+1)*8, Refresh, Permit |
| -78  | 0x172 | FreeTagItems(a0): a1=a0, FreeVec |
| -84  | 0x182 | RefreshTagItemClones(dst=a0,src=a1): copies pairs, writes 4-byte terminator only |
| -90  | 0x268 | TagInArray(tag=d0,arr=a0): linear scan, 0-terminated |
| -96  | 0x234 | FilterTagItems(list=a0,arr=a1,logic=d0): tag=1 on `in^!logic`; returns kept count |
| -102 | 0x33a | CallHookPkt: `push a0@(8); rts` — tail-jumps to hook+8 |
| -108 | 0x278 | reserved |
| -114 | 0x278 | reserved |

## Clock

| LVO | entry | notes |
|-----|-------|-------|
| -120 | 0x340 | Amiga2Date(secs=d0,ClockData=a0): divuw-based, 2100 leap fix |
| -126 | 0x3d8 | Date2Amiga(ClockData=a0) → secs |
| -132 | 0x442 | CheckDate: Date2Amiga→Amiga2Date, compares 3 longs |

## Math (software; 020 stubs patched in by init)

| LVO | entry | patch |
|-----|-------|-------|
| -138 | 0x46a | SMult32 → stub@0x90 `muls.l` |
| -144 | 0x46a | UMult32 → stub@0x96 `mulu.l` (shares the generic mul) |
| -150 | 0x484 | SDivMod32 → stub@0x9c `divsl.l` |
| -156 | 0x4aa | UDivMod32 → stub@0xa2 `divul.l` |
| -162 | 0x544 | Stricmp(a0,a1): Strnicmp with count 0x7fffffff |
| -168 | 0x548 | Strnicmp(a0,a1,n=d0): case-fold via mask test |
| -174 | 0x57a | ToUpper(d0): 0xbcb48082 bitmask range test, +32/-32 fold |
| -180 | 0x57c | ToLower(d0): 0xfcf4c0c2 bitmask |
| -186 | 0x300 | ApplyTagChanges(list=a0,chg=a1): copies chg->data into matching list items |
| -192 | 0x278 | reserved |
| -198 | 0x4ee | SMult64 → stub@0xa8 `muls.l`-pair |
| -204 | 0x516 | UMult64 → stub@0xae `mulu.l`-pair |

## Structure pack/unpack

| LVO | entry | notes |
|-----|-------|-------|
| -210 | 0x5c0 | PackStructureTags(pack=a0,tbl=a1,tags=a2) |
| -216 | 0x640 | UnpackStructureTags — writes THROUGH `*ti_Data` |

Table is a longword STREAM, not {tag,pstg} pairs: only the first
pair sets the tag base; subsequent iterations read one pstg longword
each (the tag stays stale) until a `-1` pstg resyncs a new pair.
pstg==0 ends; bit29 (pack) / bit30 (unpack) entries skip one
longword.  Offset = sign-extended low word; type = pstg bits 27-28
(byte/word/long/bit); bit fields carry index in low-word bits 13-15;
unpack sign-extends byte/word when pstg bit31 set, and returns ~0/0
for bit fields (inverted when pstg bit31).

## Named objects

| LVO | entry | notes |
|-----|-------|-------|
| -222 | 0x74c | AddNamedObject(nsobj=a0,obj=a1): ns=obj[4] (default at lib+40); dup-check on ns flags bit0; Enqueue into MinList@ns+0; obj[4]=ns |
| -228 | 0x832 | AllocNamedObjectA(name=a0,tags=a1): 28+strlen+1 + (ns?62) + (us?us+3); NULL name → returns a0 (=0) |
| -234 | 0x79e | AttemptRemNamedObject: `subal a1,a1` → RemNamedObject(obj,NULL) |
| -240 | 0x6c8 | FindNamedObject(nsobj=a0,name=a1,prev=a2): shared sem; seeds a2-16 when a2 nonzero, else head; refcount++ |
| -246 | 0x8f6 | FreeNamedObject: `lea a0@(-16)` then FreeVec — arg in a0, FreeVec reads stale a1 (BUG) |
| -252 | 0x6be | NamedObjectName: `a0@(-6)` = node ln_Name |
| -258 | 0x808 | ReleaseNamedObject: refcount--; at 0 replies obj[8] msg; returns 1 |
| -264 | 0x7a0 | RemNamedObject(obj=a0,msg=a1): removes when msg≠0 or refcount==1; stores msg in obj[8], msg+10=obj; falls into ReleaseNamedObject; else replies msg with +10=0 |
| -270 | 0x134 | GetUniqueID: INTENA 0x4000 → IDNest++ → ++lib+44 → IDNest-- → 0xc000 if <0 |
| -276..-294 | 0x278 | reserved stubs (4) |

## Init (0xd8)

Stores SysBase at lib+36, clears lib_Revision (word @+22),
AllocNamedObjectA("", {ANO_NameSpace=1}) → lib+40 (default object),
then on AttnFlags&0x8e SetFunctions the 6-entry patch table at
code+0xb4 ({w voff, l fn}); AttnFlags bit7 (060) patches only the
first two entries.
