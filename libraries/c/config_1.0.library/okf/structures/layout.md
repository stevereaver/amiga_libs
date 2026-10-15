# config.library — structures & hunk layout

## File-level hunk map (2956 bytes)

```
0x000  HUNK_HEADER (0x3f3): name "", 2 hunks [0..1], sizes 0x259/0x56 longs
0x024  hunk0: HUNK_CODE (0x3e9), size 0x259 longs = 2404 B
0x024..0x987   code body
0x988  RELOC32 -> hunk1, 12 offsets (non-ascending order):
       0x486 0x2e8 0x2aa 0x8 0x6b2 0x62c 0x7de 0x77e 0x754 0x73c 0x706 0x6f0
0x9d0  HUNK_END
0x9d4  hunk1: HUNK_DATA (0x3ea), size field 0x55 longs = 340 B
       (NB: the hunk TABLE allocated 0x56 longs — see quirks)
0x9d4..0xb27  data body
0xb28  RELOC32 -> hunk0, 9 offsets: 0x124..0x144 (9 longs, ascending)
       RELOC32 -> hunk1, 9 offsets (non-ascending):
       0xa6 0xc6 0xb2 0xde 0xb6 0xaa 0xba 0x11c 0x120
0xb88  HUNK_END         (EOF at 0xb8c)
```

The header's `firsthunk=0,lasthunk=1`; the table entry for hunk 1 reads
`0x56` while the DATA tag carries `0x55` — the loader over-allocates one
longword of zeroed tail. `fixup.py` restores this after linking.

## DATA hunk (h1) layout — a4 = h1 + 0x7ffe (SAS/C small data)

| off    | contents |
|--------|----------|
| 0x00   | `"%ld"`            GetNum's default fmt |
| 0x04   | `" = "`            key/value separator literal |
| 0x08   | `"%ld"`            SetNum fmt |
| 0x0c   | `"%s = %s\n"`      new-section tail writer |
| 0x15   | `"\n"`             header separator (d6!=0) |
| 0x17   | `""`               header separator (d6==0) |
| 0x18   | `"%s[%s]\n"`       new-section header writer |
| 0x20   | `"%s = %s\n"`      append-key writer |
| 0x29   | `"%s\n"`           plain line echo |
| 0x2d   | `"%s = %s\n"`      key replace writer |
| 0x36   | `" = "`            key-match separator test |
| 0x3a   | `"\n"`             header echo sep (d6!=0) |
| 0x3c   | `""`               header echo sep (d6==0) |
| 0x3d   | `"%s%s\n"`         header echo fmt |
| 0x43   | `"%s = %s\n"`      pending-key flush fmt |
| 0x4c   | exec base cell     (written by `_opendeps` from `4.w`) |
| 0x50   | dos base cell      (`a4@(-32686)`) |
| 0x54   | intuition base cell |
| 0x58   | graphics base cell |
| 0x5c   | `"config.library"` (ln_Name / rt_Name) |
| 0x6c   | `"config 1.0 (12.10.96)"` (lib_IdString / rt_IdString) |
| 0x84   | `"Copyright (C) 1996, Adam Dawes"` (unreferenced) |
| 0xa2   | 2 pad bytes |
| 0xa4   | **RomTag**: `4afc`, matchptr→0xa4, endskip→0x154, flags 0x80 (AUTOINIT), ver **3**, type 9 (NT_LIBRARY), pri 0, name→0x5c, id→0x6c, init→0x118 |
| 0xbe   | **datatab** (InitStruct, 40 B) — see below |
| 0xe5   | pad byte |
| 0xe6   | `"graphics.library"` |
| 0xf7   | `"intuition.library"` |
| 0x109  | `"dos.library"` |
| 0x118  | **InitTable**: `{dsize=0x36, functab→0x128, datatab→0xbe, initfn→h0+0x6fc}` |
| 0x128  | **functab**: 8 longs → h0+`{0x738,0x750,0x778,0x7da,0x0,0x2a0,0x2de,0x47c}` + `0xffffffff` |
| 0x14c  | libbase cell (written by `_initfn`) |
| 0x150  | 4 pad bytes to endskip 0x154 |

## datatab (h1+0xbe) — extended-offset InitStruct forms

```
e000 0008 0900      INITBYTE  ln_Type     @8   = 9   (NT_LIBRARY)
800a 0000005c       INITLONG  ln_Name     @10  = "config.library"
e000 000e 0600      INITBYTE  lib_Flags   @14  = 6   (CHANGED|SUMUSED)
d000 0014 0003      INITWORD  lib_Version @20  = 3
d000 0016 0000      INITWORD  lib_Revision@22  = 0
8018 0000006c       INITLONG  lib_IdString@24  = "config 1.0 (12.10.96)"
0000                end
```

`0xe0/0xd0/0xc0` = byte/word/long with offset = `(lowbyte<<16)|word`;
`0xa0/0x90/0x80` = same with 8-bit offset in the command low byte.

## Library-private fields (dsize 0x36; allocated PosSize = 34 + 0x36 = 88)

| off   | field |
|-------|-------|
| +0x20 | lib_OpenCnt (word) |
| +0x22 | seglist (h0 base), set by initfn |
| +0x26 | exec base (SysBase), set by initfn |
| +0x2a | dos.library base |
| +0x2e | intuition.library base |
| +0x32 | graphics.library base |

## SetStr line-node (14 bytes, AllocVec MEMF_CLEAR)

```
+0  ln_Succ   +4  ln_Pred   +8  ln_Type   +9  ln_Pri   +10 ln_Name(=line)
```
i.e. a `struct Node` whose `ln_Name` is the AllocVec'd line copy;
AddTail'ed onto a list header on the caller's stack frame.

## CODE hunk (h0) layout

Pure code, 0x000..0x963; 0x964 pad. Sections: SetStr 0x000, SetNum
0x2a0, GetStr 0x2de, GetNum 0x47c, list/str helpers 0x4d4..0x627,
dep management 0x628..0x6fb, initfn 0x6fc, lifecycle vectors
0x738..0x7e7, LVO shim wrappers 0x7e8..0x947 (incl. `_putch` 0x944),
reg-save stubs 0x948..0x963.
