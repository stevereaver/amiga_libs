---
file: defects
---
# Findings

- **Silent dep-fail accepted**: in Open(), failed
  OpenLibrary for utility.library (->+44) and
  layers.library (->+52) branch to the *success* tail
  (opencnt++, return lib).  A subsequent utility
  FindTagItem call or the CYBI patcher (`layers+52=0` ->
  read NULL+20) then crashes. dos fail calls
  CloseLibrary(NULL) (a1=d0=0 from the failed open).
- **layers.library leak on late fail**: graphics/
  cgxsystem/cybergraphics failure paths close gfx (0x284
  path closes intuition+utility+dos; 0x25c/0x22a add
  cgxsystem) but never close layers+52 (opened earlier).
- **expansion.library opened and kept**: result tested
  then held only in a2 — permanent OpenLibrary count
  (anchor vs leak; cannot be closed later since base is
  discarded).
- **Close is a bare decrement**: never unpatches the two
  layers hooks, never closes any dep, never checks
  opencnt==0 for deferred expunge. Expunge always
  returns 0 — the lib can never be flushed once loaded
  (consistent for a resident patch lib).
- **020 == 040**: the two shipped builds differ in a
  single byte (idstring "68020" vs "68040"); identical
  code/relocs/symbols — no 68020/68040-specific codegen
  at all despite the labels.
- **External CYBI installs**: 4 of 6 CYBI records are
  never referenced inside this binary — they are found
  by 'CYBI' magic-scan (CGX3-side, presumably cgxsystem/
  cybergraphics) and patched into the window/layer
  syscall path (intuition MoveWindow/SizeWindow/
  MoveSizeWindow/ActivateWindow shapes inferred from
  arg counts + the "ActivateWindow wnd %08lx" KPrintF).
- **Single-VLayer guard**: CreateVLayerHandleTagList
  returns 0 whenever the vlayer list (lib+174) is
  non-empty (tailpred != list head) — at most one
  VLayerHandle may exist at a time in this build.
- **KPrintF debug hunk**: h3 + the h2->h3 jmp @h2+0x514
  keep a serial-debug (KPrintF/KDoFmt) tail wired into
  the ActivateWindow hook path; HUNK_SYMBOL records ship
  the helper names in the binary.
- **Oracle flood**: hook/vlayer probes walk unmapped
  arg chains -> ~25M deterministic invalid reads under
  machine68k (counter in work/oracle.py); identical for
  orig and rebuild.
