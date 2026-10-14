# amisslmaster.library 5.27 — binary layout

File: 2512 bytes.  Header: `03f3`, 2 hunks (CODE 0x18a longs=1576B,
DATA 0xb longs=44B).  Then RELOC32 (10 rels into hunk0, 1 into hunk1),
SYMBOL hunk (full function names), END, DATA hunk + its RELOC32 +
SYMBOL + END.  (Debug hunks referenced by symbols but content hunks
are `__debug_*_start = 0x2c` aliases — the DWARF data itself is not
in this file.)

## CODE hunk map

| code+ | contents |
|-------|----------|
| 0x000 | `moveq #-1,d0; rts` entry stub |
| 0x004 | "amisslmaster.library\0" |
| 0x019 | "amisslmaster.library 5.27 (wolfSSL-Wrapper)\r\n\0" |
| 0x047 | "dos.library\0" |
| 0x054 | mLibInit — fills header by hand, OpenLibrary(dos,36)->+46 |
| 0x0a0 | mLibOpen / 0x120 mLibClose / 0x16e mLibExpunge / 0x192 mLibNull |
| 0x0c4 | inner expunge worker (stack-arg, shared by Close+Expunge) |
| 0x1b2 | InitAmiSSLMaster |
| 0x1d0 | "amissl.library\0" (sits inside the OpenAmiSSL region) |
| 0x1f8 | OpenAmiSSL / 0x254 CloseAmiSSL / 0x274+0x278 cipher stubs |
| 0x27a..0x322 | fmt strings ("OpenAmiSSLTagList apiVersion", "  amisslBase", "  Zweig: ...", "  InitAmiSSLA rc", "OpenAmiSSLTagList -> 0 (OK)") |
| 0x324 | OpenAmiSSLTagList |
| 0x484 | InitTable: datasize 0x32, functab=0 ->reloc-> hunk1, datatab=0, initfn=0x54 |
| 0x494 | RomTag `4afc` — endskip=0x494 (self), EXTRA relocated long =0x4ae, flags 0x80 ver5 type9 pri0, name->4, id->0x19, init->0x484 |
| 0x4ae | "RAM:awmaster.log\0" + pad |
| 0x4c0 | debug logger (open/seek-end/write/close per line) |

## DATA hunk (hunk1)

44 bytes: `_mFuncTable` — 10 absolute longs (all relocs into hunk0)
+ `ffffffff` terminator.

## Lib private data (dataSize 50)

| off | field |
|-----|-------|
| +8  | ln_Type = 9 (written by mLibInit) |
| +10 | ln_Name -> "amisslmaster.library" |
| +14 | lib_Flags = 6; bit3 doubles as deferred-expunge |
| +20 | version 5 / +22 revision 27 / +24 idstring |
| +32 | opencnt (word) |
| +34 | ExecBase (a6 at init) |
| +38 | seglist |
| +42 | AmiSSLBase (opened lazily by OpenAmiSSL/TagList) |
| +46 | DOSBase (also doubles as the logger enable flag) |
