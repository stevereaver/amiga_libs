# cyberlayers 40.8.library — OKF index

## Identity

| field    | value |
|----------|-------|
| libname  | `cyberlayers.library` |
| version  | 40.8 — `"cyberlayers.library 40.8 (02.01.96) © by Vision Factory Development\r\n"` |
| size     | 2884 bytes |
| format   | hunk: CODE(2116 B) + CODE(668 B), hunk0 relocs in RELOC32SHORT form |
| resident | AUTOINIT (`rt_Flags = 0x80`), v40, pri 0, rt_Init -> h0+0xc2 InitTable, rt_EndSkip -> h1+0x29c (end of file) |
| purpose  | CyberGraphX layers accelerator (Vision Factory = the CGX authors). At init it clones the layers.library Resident into AllocVec'd RAM as "layersdummy.library", InitResident()s the clone, re-points all 32 public layers vectors (-30..-216) of the running layers.library at the clone's jump-table targets, rewrites `jsr pc@(d16)` calls inside the clone that reach its SwapBits vector into `jsr a6@(-126)`, then SetFunctions six of its own hooks into layers.library (-36/-60/-66/-126/-180/-186). The hooks accelerate SMART-refresh and CGX-native-bitmap paths. |

## Reconstruction

- **Approach**: pure 68k assembly, byte-identical target. Compiler
  fingerprints: `cmpw #imm,dn` emitted as `b07c` (non-cmpi form),
  explicit zero displacements (`a2@(0)`, `sp@(0)`), `moveal 4:l`
  abs-long SysBase loads alongside abs.w loads, `movemw` single-reg
  pushes, packed Resident layout, word-offset functab.
- **Source**: `source/cyberlayers_h0.s` (stub+RomTag+strings+InitTable+
  all hunk0 code + SwapBits CYBL record), `source/cyberlayers_h1.s`
  (5 CYBL records + 5 patched vectors + rect helper),
  `source/Makefile` + generated `hunks.x`, `source/fixup.py`
  (re-emits RELOC32SHORT records in the original group order and
  verifies byte-identity against `../binary/`).
- **Result**: `source/cyberlayers.library` byte-identical to the
  original (MD5 `51ee1a5be1b9c2af4cf7740c3b91d591`).
- **Runtime**: `work/oracle.py` — machine68k harness; fake exec
  (FindResident/InitResident/SetFunction/AllocVec/CopyMem/OpenLibrary/
  Remove/FreeMem…), a packed fake layers Resident, a layersdummy base
  with `jmp` vector table, fake graphics/cybergraphics bases, and a
  `*(a6+34)` "engine" base for the SwapBits alloc/blit/free calls.
  Original and rebuilt traces are identical (orig.log == new.log).

## Docs

- `functions/vectors.md` — own 4 vectors, the 6 patched layers
  vectors, and all internal helpers.
- `structures/layout.md` — hunks, RomTag/InitTable/datatab, lib base,
  CYBL records, structures touched.
- `findings/quirks.md` — packed-resident copy, `jsr pc@` rewrite,
  cache-table overrun, dead code, unbalanced fail path, compiler
  idioms.
- `log.md` — work log.
