# config.library vectors

Functab at h1+0x128, eight absolute-long entries + `ffffffff`.
SAS/C register calling convention: args in d0-d3 (+stack).

| LVO | fn | signature / behaviour |
|-----|----|-----------------------|
| -6  | _open (0x750)    | opencnt++, clear LIBF_DELEXP, return libbase |
| -12 | _close (0x768)   | opencnt--; if 0 and DELEXP -> expunge, return seglist |
| -18 | _expunge (0x790) | if opencnt: set DELEXP, ret 0; else Remove + FreeMem(lib-negsize, neg+pos) + _closedeps (CloseLibrary dos/intuition/graphics), return seglist |
| -24 | _nullv           | `moveq #0,d0; rts` |
| -30 | _setstr (0x000)  | `setstr(file=d0, section=d1, key=d2, value=d3)` — opens file MODE_OLDFILE (1005), FGets-parses every line into a local MinList (strip trailing \n, AllocVec+strcpy+listadd), closes; reopens MODE_NEWFILE (1006), VFPrintf's each line back — writing `[sec]` headers as `%s%s\n` (sep before later sections) and `key = val\n` pairs, substituting the value where section+key match; on a miss appends `%s = %s\n` key/value into the matching section. Frees the list; returns 1 |
| -36 | _setnum (0x1d8)  | `setnum(file,section,key,long=d3)` — sprintf %ld into stack buf, delegates to _setstr |
| -42 | _getstr (0x2de)  | `getstr(file=d0, section=d1, key=d2, out=d3)` — opens MODE_OLDFILE, scans `[sec]`/`key = ` lines (strnicmp), copies value into out, closes; returns nonzero-ish on hit |
| -48 | _getnum (0x47c)  | `getnum(file,section,key,default=d3)` — sprintf %ld of the default into a stack buf, _getstr, then dos StrToLong into a long; returns parsed value |

## Internal helpers (hunk0)

- `_listinit`/`_listadd`/`_listfree` — MinList of {succ,pred,strptr}
  nodes; listadd AllocVecs a 14B node
- `_strlen`/`_strcpy`/`_strnicmp` — libc helpers
- `_opendeps`/`_closedeps` — SysBase→_h1+0x4c, OpenLibrary
  dos/intuition/graphics v37 into _h1+0x50/0x54/0x58
- `_initfn` — stores libbase at _h1+0x14c (`_libbase`), execbase at
  lib+0x26, seglist a0 at lib+0x22, then _opendeps
- `_sprintf` — RawDoFmt wrapper writing through `_putch` (byte-store
  to a3++) — fmt arg consumed via a1=&stack-args
- `_r0a`,`_r1a`,`_r0b`,`_r1b` — constant-0/1 stubs (dead helpers)
- dos thunks (stack-args → dos d1-d3 regs): `_dos_Open`(-30),
  `_dos_Close`(-36), `_dos_FGets`(-336), `_dos_VFPrintf`(-354),
  `_dos_StrToLong`(-816)
- exec thunks: `_ex_AddTail`(-246), `_ex_AllocVec`(-684),
  `_ex_CloseLibrary`(-414), `_ex_FreeMem`(-210), `_ex_FreeVec`(-690),
  `_ex_OpenLibrary`(-552), `_ex_RemHead`(-258), `_ex_Remove`(-252)
