# rebol.library 0.2 — quirks & defects

## Structural oddities

- **rt_EndSkip = 0x1fe** points at `_ctxinit` in the middle of the
  hunk, not at the end of resident code. Harmless on disk-AUTOINIT
  but wrong for ROM residency scanning; kept verbatim.
- **IdString points at the name.** datatab entry 0x8018 stores
  `&_name` ("rebol.library"), not `&_idstr` — `version` output would
  show the bare name. The `$VER:` string itself is still emitted at
  0x31a and referenced by the RomTag.
- **IdString typo**: `(22:55:56/` — no `)` before the `/©`; the
  compiler ate the close-paren (or the author typed it).
- **Stray word 0x000e** sits after the InitStruct terminator at
  0x4c — looks like an immediate-mode datatab directive left over.
- **RELOC32 offset list is non-sorted** (descending functab offsets
  first, then InitTable/romtag fields): fixup.py rewrites the hunk
  tail to reproduce it exactly.
- **lib_Flags = 6** (LIBF_SUMUSED|LIBF_CHANGED) baked in at init —
  odd flags for a fresh library.
- **lib+43 bit0** is a private flag set by initfn; Expunge bclr's it
  and bails the first time — the library survives exactly one Expunge
  while closed.

## Real bugs (observed, preserved)

- **`_newslot` doesn't check AllocMem** (0x1a4): on NULL, `a0=0` is
  linked and `slot[0].task = ThisTask` writes to absolute **$4** —
  overwriting the SysBase longword pointer. The next `moveal 4:w,a6`
  then uses the task pointer as SysBase. Oracle trace shows the
  cascading `INVALID` accesses.
- **ctx-20 freelist never initialized**: `_ctxfree` walks whatever
  is there. Works only because in practice the node/stack bytes at
  that offset tend to be 0 — in the oracle (zeroed heap) it is a
  clean NULL; on a real Amiga it's undefined.
- **ctx-24 never initialized**: `_fputs` fallback failure (`CON:`
  open fail) sets ctx-28=20 then does `jmp *(ctx-24)` — a wild jump
  through garbage. Intended as an exit/longjmp hook, never set up.
- **Scratch-buffer contamination**: `_fmt` RawDoFmt's into ctx-64
  (buffer base) then copies until a NUL. The scratch is never
  cleared, so every format after the first drags a stale tail —
  e.g. the `SystemTagList` command arrives as
  `DH1:Rebol -cs T:RebolLibScript.6f NOT none? result [write...`
  (visible in oracle trace). The written string is still
  NUL-terminated at whatever stale byte, so behavior is deterministic
  per memory state but wrong.
- **`_minus1` writes d2** (`moveq #-1,d2`), yet `_ctxret` calls it as
  if it returned d0 — then calls `_zero392` (d0=0) and finally sets
  `moveq #-1,d0` itself. Both calls are dead.
- **`jsr _ctxzero`** in `_ctxfree` is a jsr to a bare `rts` —
  a no-op through an absolute (relocated) call.
- **`addal #0,sp`** literal no-op at 0x232 (ctxinit).
- **`Read(fh,0,0)`** before Close in `_closecon` — pointless flush.
- **`_readfile` multiplies size by 1**: a dbf loop over sp@(8) which
  the only caller always pushes as 1.
- **No `a4==0` guard**: calling RebolDo/RebolFreeResult without a
  matching Open (no ctx slot) dereferences a4=0 (`a4@(-44)` etc.)
  and jumps into low memory — oracle returns whatever d0 held.
- **SetVar length is always 3** (`moveq #3,d0` at 0x47c) regardless
  of the formatted count length — "123" overflows, "6" works.
- **`_findslot`/`_newslot`/`_findctx` read `SysBase->ThisTask`
  directly** (`a1@(276)`) instead of calling FindTask — standard but
  unsynchronized; no Forbid around the slot walk.
- **Result naming race**: `RebolLibCount` GetVar/SetVar makes
  per-task filenames unique-ish but two tasks interleaving between
  GetVar and Open collide on T: paths.

## Encoding quirks kept verbatim

- `cmpX #imm,Dn` emitted as CMP-immediate EA forms (`b0bc`, `b03c`,
  `b47c`) instead of CMPI (`0c80`/`0c00`/`0c42`) — raw `.short` used.
- `pea (d16,PC)` for pushing string constants — `487a` (not lea+push).
- `movel d0,sp@(0)` keeps the explicit zero displacement
  (`2f40 0000`) where GAS would emit `2e80`.
- `bset d2,d1` encoded `.short 0x05c1` (the "bsetb" form).
- Absolute-long `jsr`/`jmp` (`4eb9/4ef9`) for _closecon, _ctxzero,
  _ctxret — all relocated; `moveal 4:w,a6/a1` = `2c78/2278 0004`.
- `_ctxok` -> `jmp _ctxret` absolute — the only intra-hunk abs jump;
  pc-rel would have worked.
- Both short and word bsr to `_fsunlock2` (`61f6` / `6100 000a`).
