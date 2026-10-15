# rexxsupport.library 34.9 — work log

- Parsed HUNK: CODE hunk 0x970 bytes + empty BSS hunk; prefix
  stub `moveq #0,d0;rts` at code+0, RomTag at +4, InitTable
  at +0x20 {dsz=0x2e, ftab→0x30 (word-offset flavour),
  dtab→0x3e, ifn→0x5e}; 10 RELOC32 at `6 a 12 16 1a 24 28 2c
  44 56`.
- Decoded lifecycle: Open@0x80, Close@0x8e (deferred-expunge),
  Expunge@0x9c (Remove + CloseLibrary(rxs) + FreeMem),
  null@0xda, dispatcher@0xde.
- Decoded dispatcher: request block a5 (+20→task block, +31
  argcount, +40 name, +44.. args); task block T+136 = *result
  buffer pointer*, T+235 caller sigbit, T+316 port-node list;
  result flags in d7 (31 raw / 16 numeric / 17 bool / 18 empty);
  errors 1/17/18/3.
- Decoded the packed command table: `[cksum][name][max<<4|min]
  [argflags]`, 4–9-char names, case-insensitive; per-length
  sections *overlap* (a shorter record's tail is the next
  record's head); last trailer byte doubles as jtab[0]'s high
  byte.  CLOSEPORT confirmed reachable (strict BHI on length
  keeps 9 valid; empirical rxs-180 log confirms the handler).
- Identified private rexxsyslib LVOs: -126 CreateArgstring,
  -132 DeleteArgstring, -174 append-name-node, -180 find-named-
  node, -186 free-stub-chain, -198 create-port-node, -204 close-
  port-node, -210 flatten-names→argstring (d1: 0=Forbid,
  else Disable), -222 init-stub-list, -288 strlen, -294 toupper,
  -306 fmt-decimal (advances a0, width d1), -312 value→argstring,
  -474 argstring→(status,value).
- Found defects: FORWARD PutMsg uses stale d2 (not the found
  port); SHOWLIST '@' selector dead (`subqw #5` tests the char
  register); OPENPORT exists→FALSE (stale d3); TYPEPKT 'A'
  returns argc not action; GETARG out-of-range → empty;
  UnLock(0) on lock failure; err3 path leaks ALLOCMEM results.
- Reconstructed `source/rexxsupport.s` (~1060 lines) — RomTag,
  InitTable/datatab, lifecycle, dispatcher, all 23 handlers,
  tables, strings — builds via `m68k-amigaos-gcc -m68000
  -nostdlib -s` → 2528-byte HUNK with identical reloc offsets.
- Built `work/oracle.py` (machine68k): HUNK loader +
  InitResident replication + exec/dos/rexxsyslib trap model +
  fixtures (task block, port nodes, packets, exec lists, DOS
  devlist) + config knobs (OPEN_OK/ALLOC_OK/LOCKABLE/DOSRES/
  FIB_ISDIR/EXAM_OK/EXNEXT/FINDPORT/WAITRET/PORTQUEUE/
  RXS198_OK/RXS174_OK/VALCONV).
- Rebuild-vs-original fixes during bring-up: dispatcher raw
  path wrongly fell into `addqw #8` (raw results read buf+8 —
  fixed by branching to the CreateArgstring tail); FREEMEM
  branch labels resolved into OPENPORT (→ bail18); SHOWDIR
  tail `exg d4,a6` → `exg a4,a6` (rxs base restore); GETARG
  read rm_Args at +28 instead of +40.
- Oracle stub corrections along the way: rxs-198 returns the
  node (NZ) on success (caller runs `sne`); rl_* constants are
  header addresses (+8 applied by caller); -180 must visit
  terminal nodes; -210 separators only between names; -306
  right-justifies; fib_DirEntryType must be written unsigned.
- Final status: main battery + failtest byte-identical between
  original and reconstruction (only stale-a0 on error paths
  differs — a table pointer at different code offsets).

- 2026-10-15 correction: prior committed `rexxsupport.s` was a
  mnemonic re-disassembly that drifted ~20 bytes and dropped the
  trailing empty hunk record (DATA size-0 hunk + END). Replaced
  with verbatim `.byte` emission of the h0 body plus `fixup.py`
  which restores the 2-hunk header, the RELOC32 tail, and the
  empty hunk record. Build now BYTE-IDENTICAL (2524B);
  oracle re-run on the new build: RUNTIME-IDENTICAL.
