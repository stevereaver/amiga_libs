# 68020.library 40.1 (MMU) — layouts

## Hunk map (2188 bytes)

```
file+0x24  HUNK_CODE  0x54c (1320 B)   all code + patch region
file+0x570 HUNK_RELOC32 -> code: 47 relocs; -> data: 1
file+0x5ac HUNK_DATA  0x200 (512 B)    InitTable/functab/strings/tables
file+0x7b0 HUNK_RELOC32 -> code/data slots
file+0x…   HUNK_END
```

Data hunk body (at DATA):

| off  | contents |
|------|----------|
| +0x00 | InitTable: `dsize=0x70, functab→+0x10, datatab=0, initfunc→code+0x4a` |
| +0x10 | functab (37 LONGs → code, -1 terminator at +0xa4) |
| +0xa8 | "68020.library\0" |
| +0xb6 | "mmu.library\0" |
| +0xc2 | "utility.library\0" |
| +0xd2 | "expansion.library\0" |
| +0xe4 | "mathieeedoubbas.library\0" (dead — never referenced) |
| +0xfc | "mathieeesingbas.library\0" (dead) |
| +0x114| "input.device\0" (reached via the code-hunk `lea`) |
| +0x127| "$VER: 68020.library 40.1 (4.12.99) (c) 1999 The MMU.lib development group, THOR" |
| +0x1c4| patch table A (1 record + 0) |
| +0x1d0| patch table B (10 records + 0) |
| +0x1f0| patch table C (7 records + 0) |

Strings are referenced by **relocated absolute `lea`/`movel
#imm` operands inside the code hunk** (single data-hunk reloc
resolves them) — not by data-hunk pointers.

## Lib68020Base (dataSize 0x70)

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

## Patch region (inside the code hunk)

Each installed stub is preceded by a 4-byte slot the patcher
fills with SetFunction's return value (the old vector); stubs
push slot→rts to tail-call the original.

| off  | contents |
|------|----------|
| +0x000 | old ColdReboot slot / pf_coldreboot / super_coldreboot |
| +0x062 | CacheClearU trampolines ×5 (+slot each) |
| +0x0bc | AddIntServer trampoline (+slot) |
| +0x0d2 | pf_getmsg (+slot) |
| +0x106 | SetIntVector trampoline (+slot) |
| +0x11c | patch_sysbase slot, unused pad long |
| +0x124 | BeginIO patch (+slot) |
| +0x146 | AddConfigDev patch (+slot) |
| +0x166 | dead pad word |
| +0x168 | InstallExcVecs (Supervisor + CacheClearU wrapper) |
| +0x18c | super_excvec (oriw sr / movec vbr / table walk / rte) |
| +0x1b6 | patch_lib slot (this library's base) |
| +0x1ba | pf_trap3,0,5,6,4,1,2 (btst gate → fsavefix or tail-call) |
| +0x262 | pf_fsavefix (fsave/frestore frame fixup + rte) |

## Trap handler encoding

The handlers use `btst`/`movel` with **memory-indirect PC
operands** (`%pc@(patch_lib-* )@(22)` etc.) which gas cannot
emit; they are encoded as `.word` sequences in
`68020_patch.s` (with bd/od as separate words).  The
supervisor code likewise uses `.word` for the absolute-store
`movel a2,@(0,d0:w)` form.
