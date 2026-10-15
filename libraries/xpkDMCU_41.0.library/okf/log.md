# xpkDMCU 41.0 — log

- 2025: parsed hunk layout — CODE h0 (2008 B) + DATA h1 (848 B),
  RELOC32. InitTable in h1, packed RomTag at h1+0xe4.
- Identified SAS/C xpk-sublib skeleton: `a4` = _gd (h1 base); dead
  `moveq #-1;rts` entry at h0+0.
- Decoded init: stores seglist/lib/exec, opens `ppc.library` v45,
  ppc -0x1e loads `LIBS:ppc/xpkDMCU.elf`, builds port/job objects via
  ppc LVOs -0x10e/-0x126/-0x3c/-0x54/-0x150/-0x132/-0x144/-0x138
  iterator; teardown releases all + CloseLibrary.
- Mapped 10 vectors: open/close/expunge/null + info(-30), pack
  dispatcher(-36), ppc-job free(-42), null stub(-48), unpack
  dispatcher(-54), native unpack(-60).
- `work/genasm.py`: Capstone -> assembly; handled undecodable data
  islands via resync-restart + raw `.short` fills; fixed gas
  canonicalizations (moveq immediates, 68020 indexed lea under
  -m68000).
- Linked with m68k-amigaos-gcc; body identical; `source/fixup.py`
  rewrites RELOC32 group order to match original.
- **Byte-identical**: MD5 `ac4a428b012daca082907b3286036c1b` (3152 B).
- `work/oracle.py` (machine68k): init + full ppc protocol, all 10
  vectors exercised, deferred+real expunge. Orig vs rebuild:
  **RUNTIME-IDENTICAL** (`work/orig.log` == `work/rebuild.log`).
- Found/documented defect: ppc-job creation path calls through
  `_gd+0x7c` without checking ppc.library opened (null-A6 wild call
  when ppc.library absent). See `findings/quirks.md`.
