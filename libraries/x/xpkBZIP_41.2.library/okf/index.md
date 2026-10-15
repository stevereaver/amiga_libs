# xpkBZIP.library 41.2 — OKF index

André Osterhues' **BZIP (PPC)** XPK sublibrary — a thin m68k
front-end that delegates all codec work to a PowerPC ELF
(`LIBS:ppc/xpkBZIP.elf`) loaded and executed via
**ppc.library** (PowerUP bridge).  The bzip2 algorithm is NOT
in this binary; the m68k side does parameter marshalling,
level→block-size selection, work-buffer management and error
mapping.  68020+ only (uses `divu.l`/`mulu.l`).

- Binary: `binary/xpkBZIP_41.2.library` — 2372 bytes, 2 hunks
  (CODE 0x508 + DATA 0x314).
- Reconstruction: `source/` — C API (`xpkBZIP.c`) + skeleton/
  data hunk (`xpkBZIP_lib.s`).

## Layout

CODE hunk: entry stub (+0, returns -1), LibInit, lifecycle,
initppc/exitppc helpers, PackerInfo, PackChunk, UnpackChunk,
PackFree, UnpackFree, code strings (ppc.library name, ELF
path, descriptor strings, message strings).

DATA hunk: InitTable at +0 (dataSize=0x32, absolute-pointer
form), functab (10 abs longs + -1) at +0x10, globals at
+0x3c..+0x83, "xpkBZIP.library" + $VER strings, **exec
Resident at +0xd0** (0x4afc, AUTOINIT, v41, NT_LIBRARY, pri2,
rt_Init→hunk start), InitStruct datatab at +0xec, 10 XpkMode
records at +0x114, XpkInfo descriptor at +0x2b8.

## Vectors (10)

| LVO | Target | Function                                |
|-----|--------|-----------------------------------------|
| -6  | libopen      | standard (opencnt++, clear DELEXP)   |
| -12 | libclose     | deferred expunge; mid-insn quirk     |
| -18 | libexpunge   | correct (SysBase/seglist via data+lib)|
| -24 | libnull      | `moveq #0,d0;rts`                    |
| -30 | packerinfo   | APTR → XpkInfo descriptor            |
| -36 | PackChunk    | PPC func 1: compress               |
| -42 | PackFree     | frees work bufs; d0 = residue        |
| -48 | libnull2     | dead stub                            |
| -54 | UnpackChunk  | PPC func 0: decompress             |
| -60 | UnpackFree   | frees work bufs; returns 0           |

## ppc.library API used (PowerUP)

- `-30` LoadObject(a0=path) → obj
- `-36` UnloadObject(a0=obj)
- `-42` RunFunction(a0=obj, a1=frame[11]) → result
- `-60` AllocVec(d0=size, d1=1) → ptr
- `-66` FreeVec(a1=ptr)

## Verification status

machine68k oracle (`work/oracle.py`): **byte-identical**
behavior vs original — InitTable/datatab/header, lifecycle +
deferred expunge, descriptor + all 10 mode records, pack
level matrix (incl. out[0] written before range check),
unpack mode-byte + all error mappings (-12/-33/-7/-17/-5/-4),
frame contents, alloc sizes, lazy-alloc gate, PackFree
residue vs UnpackFree 0, ppc-absent init failure.
The PPC-side codec itself cannot run under m68k emulation —
the m68k contract (call sequence, args, errors) is fully
verified.

## Files

- `functions/vectors.md` — vectors, ABI, ppc API, error map
- `functions/codec.md` — pack/unpack flow, frame layouts,
  level→mode math
- `structures/layout.md` — hunk map, XpkInfo/XpkMode,
  InitTable/RomTag, lib data
- `findings/defects.md` — quirks reproduced
- `log.md` — work log
