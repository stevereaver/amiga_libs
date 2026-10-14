# tdisk_4.1.library — work log

- Parsed hunk container: 1 CODE hunk, body 0x958, RELOC32 (23
  descending offsets), END.  (Corrected an early misparse where the
  body was extracted 4 bytes late, which scrambled all offsets.)
- RomTag: AUTOINIT, v4.1, NT_LIBRARY, init->0x98.  InitTable:
  datasize 0xb8, functab 11 entries + -1, datatab with 24-bit-offset
  InitStruct forms, initfn 0x1d0.
- Disassembled full 2392-byte code body.  Identified direct-hardware
  floppy library: CIAA pra $bfe001 (/TRACK0,/WPRO,/RDY), CIA-A prb
  $bfd100 (select lines), CIAB $bfdd00 (timer handshake), custom regs
  $dff000+ (DSKLEN/DSKPT/DSKBYT/ADKCON/DMACON/INTENA/INTREQ).
- Mapped all exec/disk.resource LVOs (see functions/vectors.md).
- Wrote `source/tdisk_lib.s` full asm reconstruction.
- Iterated to byte-identical output.  Fixed: gas moveq-shrinking of
  `move.l #imm` (#32/#11/#127), gas `(An)`-shrinking of `An@(0)`,
  InitStruct 24-bit forms, string layout (`\r\n` idstr end + credit
  string `\r\0`), `bras` target inside Seek's error tail, and the
  `_delay` block ordering (sits between MFMWrite's rts and Verify, not
  at file end).  Added `reorder_relocs.py` for descending RELOC32.
- Result: byte-identical (md5 208c8aec7bd8c33570eb58bbbbbecf94).
- `work/oracle.py`: machine68k harness — stubs exec (OpenResource,
  AllocMem, FreeMem, InitStruct, FindTask, Wait, GetMsg, Remove, Alert)
  and disk.resource (GetUnitID/GetUnit/GiveUnit); exercises init over
  the unit loop, Select ready/deselect, Open/Close/Expunge with
  deferred expunge, and the all-GetUnitID-fail path.  `orig.log` vs
  `rebuild.log` identical; `fail` variant identical.
