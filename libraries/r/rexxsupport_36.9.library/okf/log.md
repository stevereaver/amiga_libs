# rexxsupport.library 36.9 — work log

- Parsed HUNK: single CODE hunk 0x988 bytes (no BSS); prefix
  stub `moveq #0,d0;rts` at code+0, RomTag at +4 (ver 36,
  rev 9, pad `4e71`), InitTable at +0x20 {dsz=0x2e, ftab→0x30
  (word-offset flavour), dtab→0x3e, ifn→0x58}; 9 RELOC32 at
  `6 a 12 16 1a 24 28 2c 44`.
- Diffed against sibling 34.9 (hunk bodies + objdump):
  datatab lost the `8018` IdStr record (-6 bytes, -1 reloc);
  initfn now writes `lib_IdString` in code and calls
  `OpenLibrary("rexxsyslib.library", 0)`; LibClose shares a
  `bset/btst` subroutine with Expunge; dispatcher reworked —
  `a6`=rxs for the whole body, 400-byte scratch argstring via
  rxs-126 replaces `*T+136`, freed via rxs-132 on every exit,
  jump-table disp -4 (jtab based at the pre-jsr `exg`, 0x194).
  Command table, index tables, all 23 handlers and helpers are
  byte-identical modulo PC-relative shifts (+0x1a vs jvec).
- Reconstructed `source/rexxsupport.s` from the 34.9 source
  with the above changes; `source/Makefile` builds via
  `m68k-amigaos-gcc -m68000 -nostdlib -s`.
- Build fixes during bring-up: LibClose must `bsr` into the
  shared Expunge head (first version emitted an independent
  tail, +24 bytes); the `movel #1,d2` in `h_ALLOCMEM` had to
  be emitted as raw words (`2c3c/243c 00000001`) because the
  assembler shrunk it to `moveq` (-4 bytes); several branch
  widths needed explicit `bras`/`braw` and split labels
  (SHOWLIST `sl_bad`, GETPKT/FREEMEM `bail18`, REPLY
  `reply_ret`) to match the original encodings.
- Verification: `cmp` → the 2528-byte rebuild is
  **byte-identical** to `binary/rexxsupport_36.9.library`
  (hunk header, code, relocs, strings).
- Adapted `work/oracle.py` from 34.9: tr_rxs126 now allocates
  `ln` bytes (36.9 scratch is `CreateArgstring(0,400)`, not a
  copy of an input argstring); header comments updated for the
  new dispatcher contract (T+136 unused, a6=rxs in body).
  `work/failtest.py` copied unchanged.
- Oracle/failtest: original and rebuild produce **identical
  output** — all 23 commands, all result modes, dispatch
  errors 1/17/18/3, packet/port ops, SHOWLIST exec+devlist
  scans, lifecycle incl. deferred expunge (`expunge(open)` →
  d0=0 DELEXP set; `close->expunge` → seglist returned), the
  whole failure matrix, and the trap log shows the
  per-dispatch `argstr 400` + `delarg` pair (with `delarg 0`
  on the unknown-name path — quirk §1 confirmed).
- Final status: file-identical reconstruction with identical
  observable behavior; all quirks preserved (FORWARD stale
  d2, SHOWLIST '@' dead code, OPENPORT/TYPEPKT stale d3,
  err3 collapse, DeleteArgstring(NULL) on error paths).
