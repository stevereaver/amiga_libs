# pointer_33.2.library — OKF index

- Binary: `binary/pointer_33.2.library` (1,976 bytes, 3 hunks;
  md5 captured in git history)
- Identity: `"NuPointerLibrary 33.2 (5 Jan 1991)"`, internal name
  `pointer.library`, version 33 revision 2
- Kind: NuPointer busy-pointer library — loads
  `SYS:Prefs/presets/BusyPointer.ilbm` via iffparse at init, exposes a
  SetPointer wrapper to apply it.
- Dependencies: `intuition.library` (v33, required), `dos.library` and
  `iffparse.library` (both optional — only for the ILBM load attempt).
- Hunks: CODE (0x3e9, 0x197 lws) / DATA|CHIP (0x400003ea, 0x12 lws —
  embedded 16x16 busy-pointer image) / DATA (0x3ea, 0x16 lws —
  InitTable + data block + fixup table).
- RomTag: RTF_AUTOINIT, `rt_Init` is a DATA-hunk offset (+4) into a
  MakeLibrary-style InitTable `{dataSize=0x8a, funcTab, 0, initFn}`;
  InitTable is followed by the copied data block, and a hand-rolled
  fixup list at pd+0x50 repoints pd+0x34 at the embedded spec.
- Reconstruction: `source/pointer.c` (all functions),
  `source/pointer_lib.s` (resident module, RomTag, long-offset
  functab, InitTable, embedded CHIP bitmap, fixup table),
  `Makefile` (generated linker script orders `.datachip` before
  `.data`; `chipflag.py` sets the chip bit on hunk 1), host harness in
  `work/host.c` (built `-m32 -DHOST_TEST`).
- Verification: generated hunk structure/order/reloc groups match the
  original; CHIP bitmap hunk byte-identical; RomTag, entry stub and
  the reserved-vector tail bytes byte-identical; data block identical
  modulo relocated pointers; LibInit bytes faithful (field writes,
  0x50 copy, fixup loop, dep init, embedded fallback); PtrLoadSpec
  codegen shows the same per-BODY scan loop, CloseIFF + DOSClose
  cleanup.  Host harness passes all 8 scenarios (good load, fallback
  on dos/iffparse/parse/missing-BMHD/compressed-BMHD/missing-GRAB,
  SetPointer propagation, expunge).

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
