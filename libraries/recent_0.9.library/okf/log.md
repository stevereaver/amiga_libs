# recent.library 0.9 — work log

- Parsed original: single CODE hunk, 2848 B; file 2996 B. RomTag@h0+4,
  AUTOINIT v0 (rev 9), rt_Init -> h0+0x74, MatchTag -> h0+4.
- InitTable (h0+0x74): dsize 0x34, functab -> h0+0x84 (13 absolute
  longs + ffffffff term), datatab -> h0+0xbc, initfn -> h0+0xdc.
- Full disasm: SAS/C-compiled MRU / "recent documents" manager.
  Deps dos.library + gadtools.library; persists groups under
  `ENVARC:Recent/` with `RCNT` magic; 20-byte DateStamp-stamped
  records; GadTools NewMenu/CreateMenusA builder.
- Transcribed via Capstone generator (work/genasm.py) into
  source/recent_h0.s, then hand-corrected for exact encodings:
  CMP-immediate-EA forms, disp16-zero addressing, long-form
  immediates, `moveal #0,a3`, and the swap-loop's dual-indexed
  `movel a2@(0,d0:w),a2@(0)` all needed raw `.short`/`.long` emits —
  GAS canonicalization was the dominant source of drift.
- fixup.py rewrites the tail RELOC32 block into the original's
  count-first group order.
- Build: byte-identical — MD5 34928dfc801fd2b4e63bc67d1a362020.
- Oracle: machine68k AUTOINIT harness; fake exec (OpenLibrary,
  CloseLibrary, AllocVec, FreeVec, CopyMem, Remove, RemLibrary),
  dos (Open/Close/Read/Write/Seek/Lock/UnLock/NameFromLock/DateStamp
  with a real file fixture), gadtools (CreateMenusA/FreeMenus).
  Exercised: init dep-open chain, Open×2/Close, null stub, _load
  missing-file + fixture (RCNT + key/max/used/records), _free,
  _touch new/existing/full-evict/no-lock/bad-key paths, _addblk
  new+duplicate, _getblk copy-out, _setmax grow+shrink, _menu
  NewMenu build + CreateMenusA, _save serialization (verified
  written bytes), _savefree, expunge teardown, deferred expunge.
  Original vs rebuild traces identical.
