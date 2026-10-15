# tdisk.library 4.1 — binary layout

File: 2536 bytes.  Hunk header: 1 hunk, first=last=0, size 0x25a
longs.  CODE hunk body at file+0x20, 2392 bytes... (body 0x958 bytes
incl. pad).  Then RELOC32 (23 offsets, descending) + END.

## CODE hunk map

| code+ | contents |
|-------|----------|
| 0x000 | `bra.s` stub + `rts` (resident entry: `70004e75`) |
| 0x004 | RomTag: matchtag 4afc, endskip 0x956, flags 0x80 AUTOINIT, ver 4, type 9 NT_LIBRARY, pri 0, name->0x1e, id->0x2c, init->0x98 |
| 0x01e | "tdisk.library\0" |
| 0x02c | "tdisk library V4.1 (26 February 1988)\r\n\0" |
| 0x053 | "Copyright 1987,1988 by Fuller Computer Systems, Inc.\r\0" |
| 0x089 | "disk.resource\0" + pad |
| 0x098 | InitTable: datasize 0xb8, functab->0xa8, datatab->0xd8, initfn->0x1d0 |
| 0x0a8 | functab: 11 absolute longs + -1 |
| 0x0d8 | InitStruct datatab (type/flags/version/rev/name/idstring + unitlist seed entries; uses 24-bit offset forms) |
| 0x134 | unit InitStruct template A (GetUnitID==0 flavour) |
| 0x182 | unit InitStruct template B (GetUnitID!=0 flavour) |
| 0x1d0 | Init — OpenResource, per-unit GetUnitID/AllocMem/InitStruct loop (d2=3..0), Alert path falls into Open |
| 0x29e | Open / 0x2ac Close / 0x2c2 Expunge / 0x336 null |
| 0x33a | InitUnit — FindTask(NULL), GetUnit, Wait/GetMsg reply wait |
| 0x3b0 | UnitCleanup — GiveUnit |
| 0x3cc | Select — CIAA /RDY poll + CIA-A select lines |
| 0x43a | Seek — step/head-select via CIAB, per-step delay |
| 0x4e0 | MFMRead — DSKLEN/DSKPT DMA, DSKBYT sync wait, MFM decode, sector match |
| 0x792 | MFMWrite — MFM encode loop (0x44894489 sync marks, 0xaaaaaaaa fill), precomp select, DSKLEN write cycle, optional CIAB timer handshake (INTENA 0x4000 + icr bit4 wait) |
| 0x926 | Delay — `subq.l #1,d0; bne` busy loop |
| 0x92c | Verify — MFMRead + memcmp-style long compare (3261 longs) vs trackbuf; 0x946/+ tail |

## Library data structure (datasize 0xb8)

| off | field |
|-----|-------|
| +0e | lib_Flags byte — bit3 = deferred expunge |
| +20 | opencnt (word @ +32) |
| +22 | seglist (stored by init) |
| +26 | exec SysBase (a6 at init) |
| +2a | disk.resource base |
| +2e..+3d | unit ptrs[4] (indexed by unit# 0..3) |
| +96 | embedded list head (NewList-style init at init) |
| +4e | ptr to +96 list |
