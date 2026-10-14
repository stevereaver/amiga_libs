# streplay 33.8 — work log

- Parsed hunk file: single CODE hunk, 2308 B body + 47 same-hunk
  RELOC32 relocations.
- Decoded RomTag at hunk+4 (AUTOINIT) after a `moveq #20,d0; rts` DOS
  stub; InitTable @0x6e (dataSize 0x30), functab @0x7e (10 absolute
  longs), datatab @0xaa (e0/c0/d0 InitStruct forms), initfn @0xd6.
- Identified as "Olli"'s STReplay SoundTracker player — Paula audio
  via VBLANK interrupt server, module loading via dos.library.
- Recovered all 10 vectors: Open/Close/Expunge/Null, LoadModule,
  Unload, ModulePtr, Play, Stop, IsPlaying.
- Fully disassembled the player core: setup (pattern-count scan,
  sample table build, AUDxVOL clear), mute, interrupt handler, tick
  dispatch (self-modifying speed byte inside a `cmpiw` immediate),
  per-channel effect pass (arpeggio, portamento up/down, volume
  slide), new-row decoder (position jump, set volume, pattern break,
  filter toggle, set speed), note decoder, 36-entry period table.
- Reconstructed as pure asm (`source/streplay_lib.s`); iterative
  byte-diffing:
  - `e0`-form InitStruct entries pad to word alignment (6 B each)
    plus a pad byte after the terminator.
  - `_freebuf`'s empty-buffer branch and both `_close` branches share
    Open's `rts` at 0x110 (not the adjacent one at 0x102).
  - `_stop` tail-jumps to `_stop2` (`jmp abs`) — no trailing rts.
  - Channel state is 26 B per channel (not 30).
  - `_modbase` sits at hunk 0x900 after a 6-byte pad past the period
    table; all PC-relative reads of globals vs absolute writes.
  - `moveal %pc@(x)` is not accepted as PC-rel by gas for a-reg dest —
    used `movel %pc@(x),%a0` (emits `207a`).
- `fixup.py` rewrites the RELOC32 offset list to the original linker's
  partially-descending order (GNU ld emits ascending).
- Final binary **byte-identical**: MD5 `c810ae6677c04050c5eae2e77141f922`.
- `work/oracle.py` (machine68k): AUTOINIT datatab + init; Open/Close/
  Expunge incl. deferred expunge (DELEXP flag → Remove + FreeMem on
  last close); LoadModule via stubbed dos.library (Open/Seek×2/
  AllocMem/Read/Close; -1 open-fail, -2 alloc-fail); Play →
  AddIntServer(5) + flag 0x525a; 7 manual interrupt ticks — tick 6
  advances pattern row (patoff +0x10); Stop → RemIntServer + Paula
  mute; Unload frees the module buffer.
