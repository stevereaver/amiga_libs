# rexxserdev.library 5.02 — work log

- Parsed hunk: single CODE hunk 0x223 words; 4-byte
  `moveq #0,d0;rts` prefix stub at code+0, RomTag at code+4.
  (Early confusion about a "+4 offset convention" resolved —
  all stored offsets are standard, counted from code+0.)
- Decoded InitTable@0x20 {dsz=0x42, ftab→0x30, dtab→0x48,
  ifn→0x68}; datatab@0x48 is standard 8-bit-offset InitStruct
  (`a0`=INITBYTE, `90`=INITWORD, `80`=INITLONG per
  exec/initializers.i).
- Mapped functab: Open@0xa8, Close@0xb6, Expunge@0xca,
  null@0x11a, dispatcher@0x120.
- Decoded dispatcher: 14-entry nametab scan via utility -162
  Stricmp; i<11 resolves handle through rexxsyslib private -300;
  call convention a2=obj, a5=lib, d4=msg, reply a1/err d0.
- Identified private rexxsyslib LVOs: -126 CreateArgstring,
  -288 strlen, -300 arg→value, -306 fmt (advances a0),
  -312 value→argstring.
- Mapped all 14 API functions to serial.device commands and the
  82-byte IOExtSer field layout; decoded SerOpen's 3-channel
  object construction (read io+OpenDevice, write+ctrl sharing
  dev/unit) and teardown chains.
- Found defects: FreeMem word-size bug (matches Aminet
  RexxSerDevFix notes), SerFlush's impossible `ori.b #$60`
  R/W select (always "0"), SerStart/SerStop stubs, dead
  object-count test in Expunge.
- Reconstructed: `source/rexxserdev.c` (API + helpers),
  `rexxserdev_lib.s` (prefix stub, RomTag, InitTable, datatab,
  lifecycle, dispatcher, API stubs, tables, strings).
  Built with `-ffixed-a2 -ffixed-a5 -ffixed-d4` (GCC otherwise
  clobbers the dispatcher-supplied registers).
- Verified: machine68k oracle — byte-identical observable
  behavior vs the original across init, all 14 functions,
  io field dumps, reply strings, lifecycle/deferred expunge,
  plus a 4-case failure matrix (missing libs, OpenDevice fail,
  DoIO errors, parity matrix) — all matching.
