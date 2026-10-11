# memorymanage.library 1.01 — 68040 MMU page-table manager

- **Binary**: `binary/memorymanage_1.01(040).library`, 1816 bytes,
  single code hunk
- **Id string**: `$VER:memorymanage 1.01 (c) 2000`
- **Reconstruction**: `source/` — C (`mm.c`) + AUTOINIT skeleton and
  supervisor thunks (`mm_lib.s`); builds `memorymanage.library`
  (m68k-amigaos-gcc, `-m68000 -O2`, privileged MOVEC/PTEST/PFLUSHA in
  minimal asm)
- **Status**: complete. Header region (RomTag, init table, absolute
  functab, strings) byte-identical to the original modulo relocated
  pointers. All 11 vectors resolved; codegen reviewed
  instruction-by-instruction against IRA + raw objdump decodes.

## Layout (original)

```
code+0x000  _start: moveq #-1,d0 / rts     (LibOpen wrap stub)
code+0x004  RomTag: 0x4afc AUTOINIT v1, rt_EndSkip -> _start
code+0x01e  init table: dataSize 0x53 / functab / datatab=0 / LibInit
code+0x02e  functab: 11 x DC.L absolute pointers + ffffffff
code+0x05e  LibInit (zeroes +42/+38/+80w, stores seglist, clears +82)
code+0x082  LibOpen / Close / Expunge / null
code+0x0e8  MMUAttach (-30)
code+0x258  next_extent helper (TypeOfMem 256KB-step probe)
code+0x2a6  MMUDetach (-36)
code+0x30e  MMUWriteRegs (-60)
code+0x342  sv_loadregs (MOVEC writes + PFLUSHA, RTE)
code+0x37c  profile A (26B, installed by MMUAttach)
code+0x396  profile B (26B, written by MMUDetach)
code+0x3b0  MMUMap (-42)
code+0x56e  MMUMapIdentity (-48)
code+0x580  MMUTranslate (-66)
code+0x5d0  sv_ptest (movec dfc / ptestw (a0) / movec mmusr,d0)
code+0x5de  MMUReadRegs (-54)
code+0x612  sv_readregs (MOVEC reads, 30-byte block!)
code+0x652  "memorymanage.library"
code+0x66c  "$VER:memorymanage 1.01 (c) 2000"
```

## Table hierarchy

- Root: 128 entries x 32MB, index `(vaddr>>25)&0x7f` (rol7)
- Mid:  128 entries x 256KB, index `(vaddr>>18)&0x7f` (rol14),
  allocated 0x410 (512B table + align + 16B trailer)
- Leaf: 64 entries x 4KB, index `(vaddr>>12)&0x3f` (ror12),
  allocated 0x210 (256B table + align + 16B trailer)
- Descriptor bit1 set => entry points to a child table
  (`tableaddr | 2`); bit1 clear at root/mid level => alloc on demand.
- New child tables are pre-filled with the parent's base address so
  mappings are preserved across the split: mid gets
  `(root[i]&0xfffc0000)` stepping 0x40000, leaf gets
  `(mid[i]&0xfffff000)` stepping 0x1000.
- Trailer node: `{next, allocbase, slotptr, olddesc}` linked on
  base+42 freelist; MMUDetach walks it twice (un-patch slot <- olddesc,
  then FreeVec allocbase).

See `functions/vectors.md`, `structures/layout.md`,
`algorithms/mmu_tables.md`, `findings/defects.md`, `log.md`.
