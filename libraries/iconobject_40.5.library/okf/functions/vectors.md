# Vectors (functab @ DATA+0x100; 11 entries + FFFFFFFF terminator)

| LVO | code | sym | behaviour |
|-----|------|-----|-----------|
| -6  | 0x72e | _open | lib_OpenCnt++, clear LIBF_DELEXP(bit3 of flags+0xe); calls _loadfail: if objlist (lib+0x58) empty -> _scandt populates it. On failure calls _close and returns 0. Return d0 = libbase (via hidden `move.l a6,d0` @0x754). |
| -12 | 0x75c | _close | opencnt--; if 0 and DELEXP -> _expunge, returns seglist. Else returns 0 (hidden `moveq #0` @0x778). |
| -18 | 0x780 | _expunge | if opencnt: set DELEXP, return 0. Else: unlink via exec Remove, _closelibs, _freelist(lib+0x58) freeing each obj (CloseLibrary obj+0x12, FreeVec +0xa, FreeVec node), FreeMem(lib-neg, neg+pos), d0=seglist. |
| -24 | 0x7dc | _reserved | return 0 |
| -30 | 0x472 | _v30 | objlist walk: for each node call hook `$e(a2)` (the dtlib result) via intuition -0x27c-style tagcall {a0=obj+0xe, a1=tagpack}: builds {a1, 0, arg, 2, d7, 0x80001064} |
| -36 | 0x4e6 | _v36 | calls intuition -0x282 on arg |
| -42 | 0x502 | _v42 | objlist walk like _v30; extra tag 0x80001398, utility -0x24 check vs gd+0x164 |
| -48 | 0x59a | _v48 | -> _dispatch(a0=obj,a1=tags?) with 0x800013eb tag; returns a0 |
| -54 | 0x5be | _v54 | name lookup: scans objlist, utility -0xa2 (Stricmp-ish) on node+0x1a tails; returns node field or 0 |
| -60 | 0x63c | _v60 | wrap: _tagwalk(a0,a1,0) |
| -66 | 0x620 | _v66 | wrap: _tagwalk(a0,a1,a1) |

## Internal subs (hunk0 offsets)

- 0x000 _openlibs(lib): InitSemaphore(lib+0x2a); NewList(lib+0x58);
  opens the 4 dep libs v39 -> globals; failure -> _closelibs, ret 0
- 0x096 _loadfail(lib): if list empty -> _scandt; returns bool
- 0x0be _closelibs(lib): _freelist + CloseLibrary each dep, clr globals
- 0x12e _allocobj(name,?,pri,lib): AllocVec 0x20 (obj) + name buf,
  strcat "datatypes/"+name+".datatype", pri->ln_Pri, obj+0x16,
  +0x1a=".info"
- 0x1ba _freeobj: FreeVec name + node
- 0x1e6 _chunkfn(chunkdesc, lib): if +0x10=='icon': _allocobj; if
  +0x14=='aico' also store obj->lib+0x26; OpenLibrary(obj+0xa) ->
  obj+0x12; call dtlib -0x1e -> obj+0xe; Enqueue(lib+0x58, obj)
- 0x272 _procicon(name, lib): iffparse AllocIFF/dos Open/InitIFFasDOS/
  OpenIFF/CollectionChunk('DTYP','DTHD')/StopOnExit/ParseIFF loop/
  FindCollection -> _chunkfn per node; cleanup CloseIFF/dos Close/
  iff -0x36
- 0x34e _scandt(lib): NewList? no -- re-inits lib+0x58; dos
  ParsePatternNoCase('#?.info'), Lock('DEVS:Datatypes/'),
  CurrentDir, Examine/ExNext loop, MatchPattern-ish -0x3cc,
  -> _procicon per entry; ends on IoErr==232 -> d5=1
- 0x434 _freelist(lib): RemHead(lib+0x58) loop -> CloseLibrary(+0x12)
  + _freeobj
- 0x658 _tagwalk: objlist walk + tagpack + intuition -0x27c
- 0x6d0 _retff: return -1
- 0x6de _initfn: see index.md
- 0x7ec _newlist: MinList init (head->&tail? {4,0,head} at +4)
- 0x800 _dispatch: method dispatcher — walks a2 obj chain, pushes
  continuation L86e + hook $8(a0)/$18(a0), rts = tail call;
  L86e: pop a2; rts
- 0x8e4 _strcat: append a1 to a0
