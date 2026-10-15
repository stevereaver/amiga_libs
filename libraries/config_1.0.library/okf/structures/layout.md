# config.library structures

## File layout

```
HUNK_HEADER: names=0, hunks=2, first=0, last=1,
             sizes={0x259=2404B code, 0x56 (hunk1 alloc: ONE LONG
                    bigger than the 0x55-long body it stores)}
hunk0: HUNK_CODE 2404B  + RELOC32 {1 group -> h1, scrambled order}
                        + HUNK_END
hunk1: HUNK_DATA 0x55LW + RELOC32 {->h0, ->h1 scrambled}
                        + HUNK_END
```

## hunk1 (DATA) map

| off | content |
|-----|---------|
| 0x00-0x4b | printf fmt strings: `%ld`, ` = `, `%s = %s\n`, `\n`, `%s[%s]\n`, `%s\n`, `%s%s\n` |
| 0x4c | _SysBaseG |
| 0x50 | _DOSBaseG |
| 0x54 | _IntuitionG |
| 0x58 | _GfxBaseG |
| 0x5c | `config.library\0` |
| 0x6c | `config 1.0 (12.10.96)\0` |
| 0x84 | `Copyright (C) 1996, Adam Dawes\0` |
| 0xa4 | RomTag (AUTOINIT, **ver=3**, type 9) — resident lives in DATA |
| 0xbe | datatab (InitStruct: type 9, name, flags 6, ver 3, rev 0, idstr) |
| 0xe6 | `graphics.library`, 0xf7 `intuition.library`, 0x109 `dos.library` |
| 0x118 | InitTable {dsize=0x36, functab→0x128, datatab→0xbe, initfn→h0} |
| 0x128 | functab: 8 absolute entries + ffffffff |
| 0x14c | _libbase cell (written by initfn), +0x150 pad |

## lib privdata (dsize 0x36)

```
+0x22 seglist (from initfn a0)
+0x26 ExecBase (from initfn a6)
+0x2a/+0x2e/+0x32  (reserved; dep bases live in the data hunk globals)
```

## INI record nodes

listadd nodes are 14B: {ln_Succ, ln_Pred, name->str} — strings
AllocVec'd separately and FreeVec'd on _listfree.
