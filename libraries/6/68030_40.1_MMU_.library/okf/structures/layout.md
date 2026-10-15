# 68030.library 40.1 (MMU) — layouts

## Hunk map (2196 bytes)

```
file+0x24  HUNK_CODE  0x52c (1324 B)   all code + patch region
file+0x…   HUNK_RELOC32 -> code/data relocs
file+0x…   HUNK_DATA  0x200 (512 B)    InitTable/functab/strings/tables
file+0x…   HUNK_RELOC32 -> data relocs
file+0x…   HUNK_END
```

Data hunk body (at DATA):

| off  | contents |
|------|----------|
| +0x00 | InitTable: `dsize=0x70, functab→+0x10, datatab=0, initfunc→code+0x4a` |
| +0x10 | functab (37 LONGs → code, -1 terminator at +0xa4) |
| +0xa8 | "68030.library\0" |
| +0xb6 | "mmu.library\0" |
| +0xc2 | "utility.library\0" |
| +0xd2 | "expansion.library\0" |
| +0xe4 | "mathieeedoubbas.library\0" (dead — never referenced) |
| +0xfc | "mathieeesingbas.library\0" (dead) |
| +0x114| "input.device\0" (reached via the code-hunk `lea`) |
| +0x127| "$VER: 68030.library 40.1 (4.12.99) (c) 1999 The MMU.lib development group, THOR" |
| +0x1c4| patch table A (1 record + 0) |
| +0x1d0| patch table B (10 records + 0) |
| +0x1f0| patch table C (7 records + 0) |

Strings are referenced by **relocated absolute `lea`/`movel
#imm` operands inside the code hunk** (single data-hunk reloc
resolves them) — not by data-hunk pointers.

## Lib68030Base (dataSize 0x70)

| off | field |
|-----|-------|
| +0x00 | struct Library (34 B): ln_Type=9, ln_Name=data+0xa8, lib_Flags=6, NegSize=222, PosSize=112, Version=40, Revision=1, IdString=data+0x127 |
| +0x22 | FPUFlags byte — FPUControl get/set target, also the 68881-handler gate bits |
| +0x24 | 'THOR' magic (0x54484f52) |
| +0x2b | CPUFlags byte — bit0: no 68881 (skip excvec install), bit1: mmu.library GetMMUType()==0 |
| +0x2c | seglist (a0 at init) |
| +0x30 | SysBase copy — all patch helpers reload a6 from here |
| +0x34 | utility.library base |
| +0x38 | expansion.library base |
| +0x44 | mmu.library base |
| +0x48 | input.device node (from SysBase->DeviceList) |
| +0x50..+0x6b | saved 68881 exception vectors 48-54 (table C order: vec 53,51,54,52,48,49,50) |
| +0x6c..+0x6f | unused tail |

## Patch region (inside the code hunk, base at code+0x2a6)

Each installed stub is preceded by a 4-byte slot the patcher
fills with SetFunction's return value (the old vector); stubs
push slot→rts to tail-call the original.

| off  | contents |
|------|----------|
| +0x000 | old ColdReboot slot / pf_coldreboot / super_coldreboot (0x38 B: pmove tc+tt0+tt1, reset) |
| +0x06a | CacheClearU trampolines ×5 (+slot each): +0x6e..+0xba |
| +0x0c4 | AddIntServer trampoline (+slot), fn +0xc8 |
| +0x0da | pf_getmsg (+slot), fn +0xde |
| +0x10e | SetIntVector trampoline (+slot), fn +0x112 |
| +0x124 | patch_sysbase slot, unused pad long |
| +0x12c | BeginIO patch (+slot), fn +0x130 |
| +0x14e | AddConfigDev patch (+slot), fn +0x152 |
| +0x170 | dead pad word |
| +0x172 | InstallExcVecs (Supervisor + CacheClearU wrapper) |
| +0x194 | super_excvec (oriw sr / movec vbr / table walk / rte) |
| +0x1be | patch_lib slot (this library's base) |
| +0x1c2 | pf_trap3,0,5,6,4,1,2 (btst gate → fsavefix or tail-call) |
| +0x26a | pf_fsavefix (fsave/frestore frame fixup + rte) |

## Trap handler encoding

The handlers use `btst`/`movel` with **memory-indirect PC
operands** (`%pc@(patch_lib-* )@(22)` etc.) which gas cannot
emit; they are encoded as `.word` sequences in
`68020_patch.s` (with bd/od as separate words).  The
supervisor code likewise uses `.word` for the absolute-store
`movel a2,@(0,d0:w)` form.
