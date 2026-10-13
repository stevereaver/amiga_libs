# 68020.library 46.4 — Layouts

## Private library base (InitTable dataSize = 0x74, four bytes larger
## than 43.2's 0x70)

| off | size | field |
|-----|------|-------|
| 0x00 | 34 | `struct Library` (node, flags, neg/pos sizes, version, revision, idstring, sum, opencnt) |
| 0x22 | 1 | **FPUFlags** — FPUControl flag byte; bits 0-6 gate the 68881 fsave-frame fixups. Ships as 0 (revision word = 0x0003, so the byte is the revision's high byte) |
| 0x23 | 1 | pad |
| 0x24 | 4 | `'THOR'` signature |
| 0x28 | 2 | pad |
| 0x2a | 1 | pad |
| 0x2b | 1 | CPUFlags: bit0 = no 68881, bit1 = mmu.library GetMMUType == NONE |
| 0x2c | 4 | seglist (LibInit a0) |
| 0x30 | 4 | ExecBase |
| 0x34 | 4 | utility.library base |
| 0x38 | 4 | expansion.library base |
| 0x3c | 4 | pad |
| 0x40 | 4 | pad |
| 0x44 | 4 | mmu.library base |
| 0x48 | 4 | input.device node (FindName on DeviceList) |
| 0x4c | 4 | pad |
| 0x50 | 4 | **new in 46.3/46.4** — reserved longword, never written or read |
| 0x54-0x6f | 28 | TrapSave[7] — saved 68881 exception vectors (was 0x50-0x6b in 43.2) |
| 0x70 | 4 | pad |

## Data hunk (536 bytes)

| off | contents |
|-----|----------|
| 0x00 | InitTable: dataSize 0x74, funcTab -> +0x10, dataTab 0, initFunc -> code+0x4a |
| 0x10-0xa0 | function table, 37 longs |
| 0xa4 | -1 terminator |
| 0xa8 | "68020.library" |
| 0xb6 | "mmu.library" |
| 0xc2 | "utility.library" |
| 0xd2 | "expansion.library" |
| 0xe4 | "mathieeedoubbas.library" (dead data, never opened) |
| 0xfc | "mathieeesingbas.library" (dead data) |
| 0x114 | "input.device" |
| 0x121 | "p5emu.library" (new in 46.3/46.4) |
| 0x12f | "$VER: " + idstring (ln_IdString points at +0x135, past the cookie) |
| 0x18c | patch table A: `{long code+0x34e, {0x30, -726, 4}, 0}` — ColdReboot |
| 0x198 | patch table B: `{long code+0x34e, 10 records, 0}` — exec + input.device |
| 0x1dc | exception table: 7 × `{long handler, word vbroff, word saveoff}` + terminator |

## Patch record format

`{liboff.w, vecoff.w, fnoff.w}` — liboff indexes library-base fields
(0x30 = ExecBase slot, 0x48 = input.device), vecoff is the signed LVO,
fnoff is an offset into the patch region (code+0x34e).  The longword
before each stub (`fn-4`) receives the old vector.

## Patch region (code+0x34e)

`+0` ColdReboot old-vec slot; `+4` pf_coldreboot; `+0x32`
super_coldreboot; `+0x88..+0xf9` six 18-byte {slot+stub} trampolines
(AddLibrary 0x8c, CloseLibrary 0x9e, AddDevice 0xb0, AddResource 0xc2,
AddTask 0xd4, AddIntServer 0xe6); GetMsg at 0xfc; exec-36 at 0x138;
SetIntVector at 0x148; `+0x15a` patch_sysbase slot; `+0x15e` unused pad;
`+0x162` beginio old-vec slot; `+0x166` pf_beginio; `+0x184` dead pad
word; `+0x186` InstallExcVecs; `+0x1a8` super_excvec; `+0x1d2`
patch_lib slot; `+0x1d6` the seven 68881 handlers (trap3, trap0,
trap5, trap6, trap4, trap1, trap2 — 26/24/24/24/24/24/22 bytes);
`+0x27e` pf_fsavefix.
