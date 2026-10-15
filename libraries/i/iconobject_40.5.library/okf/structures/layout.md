# Layouts

## DATA hunk (hunk1, 368 B) — SAS/C absolute-data, a4==0 (_LinkerDB)

| off  | what |
|------|------|
| +0x000 | "iconobject.library\0" (+pad) — also == _LinkerDB target of all `lea.l _libname,a4` init insns |
| +0x014 | "$VER: iconobject.library 40.5 (13 Sep 2005 20:01:11)  (SAS/C 6.58) \xa9" + "1999-2006 The Scalos Team\0" |
| +0x072 | "iffparse.library\0" (+pad) |
| +0x084 | "dos.library\0" |
| +0x090 | "intuition.library\0" |
| +0x0a2 | "utility.library\0" |
| +0x0b2 | "datatypes/\0" (+pad)   path prefix |
| +0x0be | ".datatype\0"          suffix |
| +0x0c8 | "datatypes/\0" (+pad)  2nd copy (used by _allocobj) |
| +0x0d4 | ".datatype\0"          2nd suffix |
| +0x0de | ".info\0"              stored at obj+0x1a |
| +0x0e4 | "#?.info\0"            dos pattern |
| +0x0ec | "DEVS:Datatypes/\0"    scan dir |
| +0x0fc | .long 0 (+0xfc / +0xfe referenced as tag-end/word 0) |
| +0x100 | functab: 11 .long -> hunk0 + 0xffffffff |
| +0x130 | InitTable: 0x68, functab, 0 (no datatab), _initfn |
| +0x140 | RomTag (RTC_MATCHTAG, AUTOINIT, v40, NT_LIBRARY) |
| +0x15a | EndSkip target (2 pad bytes) |
| +0x15c | _gd_sysb       SysBase (stashed by initfn) |
| +0x160 | _gd_intuition  IntuitionBase |
| +0x164 | _gd_utility    UtilityBase |
| +0x168 | _gd_dos        DOSBase |
| +0x16c | _gd_iffparse   IFFParseBase |

## Library private data (lib base, lib_PosSize dataSize=0x68)

| off  | what |
|------|------|
| +0x22 | seglist (stored by initfn) |
| +0x26 | last 'aico' chunk object (written by _chunkfn) |
| +0x2a | SignalSemaphore (InitSemaphore at open-libs) — 46 B |
| +0x58 | MinList of loaded icon objects (NewList at init) — 12 B |

## Object node (AllocVec 0x20)

| off  | what |
|------|------|
| +0x00/+0x04 | ln_Succ / ln_Pred |
| +0x09 | ln_Pri = chunkdesc +0x1f byte |
| +0x0a | -> "datatypes/<name>.datatype" buffer (separate AllocVec) |
| +0x0e | result of dtlib LVO -0x1e call |
| +0x12 | datatype sub-class lib base (OpenLibrary obj+0xa) |
| +0x16 | chunkdesc +0x14 field ('aico' longword passed through) |
| +0x1a | -> ".info" string const |
| +0x1e | .w = 5 |

## Chunk descriptor (from FindCollection nodes: *(node+8))

| off  | what |
|------|------|
| +0x04 | self-relative offset to name string |
| +0x10 | 'icon' magic long |
| +0x14 | 'aico' magic long (triggers lib+0x26 store) |
| +0x1e | word -> ln_Pri |
