# 68020.library 43.2 (MMU) — layouts

## Hunk map (2192 bytes)

```
file+0x24  HUNK_CODE  0x524 (1316 B)   all code + patch region
file+0x…   HUNK_RELOC32 -> code hunks
file+0x…   HUNK_DATA  0x204 (516 B)    InitTable/functab/strings/tables
file+0x…   HUNK_RELOC32 -> code/data slots
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
| +0x127| "$VER: 68020.library 43.2 (28.05.2014) (c) 1999 The MMU.lib development group, THOR" |
| +0x178| patch table A (1 record + 0) |
| +0x184| patch table B (10 records + 0) |
| +0x1c8| patch table C (7 records + 0) |

Strings are referenced by **relocated absolute `lea`/`movel
#imm` operands inside the code hunk** (single data-hunk reloc
resolves them) — not by data-hunk pointers.

## Lib68020Base (dataSize 0x70)

| off | field |
|-----|-------|
| +0x00 | struct Library (34 B): ln_Type=9, ln_Name=data+0xa8, lib_Flags=6, NegSize=222, PosSize=112, Version=43, Revision=2, IdString=data+0x127 |
| +0x22 | FPUFlags byte — FPUControl get/set target, also the 68881-handler gate bits |
| +0x24 | 'THOR' magic (0x54484f52) |
| +0x2b | CPUFlags byte — bit0: no 68881 (skip excvec install), bit1: mmu.library GetMMUType()==0 |
| +0x2c | seglist (a0 at init) |
| +0x30 | SysBase copy — all patch helpers reload a6 from here |
| +0x34 | utility.library base |
| +0x38 | expansion.library base (opened but no longer patched in 43.2) |
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
| +0x000 | old ColdReboot slot / pf_coldreboot / super_coldreboot (0x3a B) |
| +0x06c | CacheClearU trampolines ×5 (+slot each): AddLibrary +0x70, CloseLibrary +0x82, AddDevice +0x94, AddResource +0xa6, AddTask +0xb8 |
| +0x0c6 | AddIntServer trampoline (+slot), fn +0xca |
| +0x0dc | pf_getmsg (+slot), fn +0xe0 — early empty check added |
| +0x118 | pf_lvo36 exec-36 trampoline (+slot), fn +0x11c |
| +0x128 | SetIntVector trampoline (+slot), fn +0x12c |
| +0x13e | patch_sysbase slot, unused pad long |
| +0x146 | BeginIO patch (+slot), fn +0x14a |
| +0x168 | dead pad word |
| +0x16a | InstallExcVecs (Supervisor + CacheClearU wrapper) |
| +0x18c | super_excvec (oriw sr / movec vbr / table walk / rte) |
| +0x1b6 | patch_lib slot (this library's base) |
| +0x1ba | pf_trap3,0,5,6,4,1,2 handlers (btst gate → fsavefix or tail-call) |
| +0x262 | pf_fsavefix (fsave/frestore frame fixup + rte) |

(43.2's AddConfigDev patch and its slot are gone; the
exec-36 stub occupies +0x118..+0x127 instead.)

## Handler encoding

The handlers use `btst`/`movel` with **memory-indirect PC
operands** (`%pc@(patch_lib-*)@(22)` etc.) which gas cannot
emit; they are encoded as `.word` sequences in
`68020_patch.s` (with bd/od as separate words).  The first
handler (bit3) uses `bra.w` to pf_fsavefix, the middle five
`bra.s`, the last (bit2) a direct `bnes` — identical to the
40.1 encodings.

## super_coldreboot tail (43.2)

```
lea 0x1000000,a0
subal a0@(-20),a0        ; ROM base
moveal a0@(4),a0         ; reset PC
subql #2,a0
bras 2f
3: reset                 ; new in 43.2
   jmp a0@
2: bras 3b
```

The odd forward/backward `bras` pair brackets the
`reset; jmp` — reproduced verbatim from the shipped binary
(40.1 had `bras 2f; .word 0; 2: nop; jmp a0@` instead).
