# xpkSQSH 1.2 (000) — log

- Confirmed 000 is the 68000 twin of 1.2(020): same idstr/revision,
  same 10-vector functab layout, zero bitfield opcodes in the hunk,
  no AttnFlags CPU gate in LibInit. Descriptor differs only in
  longname ("Squash V1.2") and Pack/UnpackSpeed (0x0c/0x3c).
- Reused the 1.2(020) codec source; 68000 build required: native
  `divu.w`/`mulu.w` asm helpers for the litcost/mcost arithmetic,
  a `__mulsi3` stub for GCC's strength-reduced `bitpos += w` multiply,
  and removal of the skeleton's 020 CPU gate.
- Machine68k oracle (same harness as the 020): initial builds
  diverged mid-stream. Root-caused via raw m68k disassembly of the
  candidate-compare loop: the node slot is selected by the final
  `cmpm.b` byte relation (`ca[-1] < cb[-1]`, signed), via `dbne` ->
  `bles` -> `addqw #2,a3` — not by remaining match length. Fixed the
  slot expression; all 13 packable streams then byte-identical.
- Fixed `putbits` to write zero-bits explicitly (`bfins` semantics);
  `|=` only left stale buffer bytes visible in streams.
- Same source defects existed in the 020 sibling — applied the slot
  fix there too, plus the `a0`-register xsp parameters (the 020 build
  had read xsp from the stack; latent because it was only
  host-verified) and the same putbits fix. 020 rebuild then produced
  all 16 streams byte-identical to its original under machine68k.
- Earlier "emulator flag bug" theories (cmpw/bhi carry-on-equality)
  were disproven by micro-tests — machine68k compares are correct;
  the observed gates are strict `> 7` (opcode 0x62 is BHI).
- Verified: lifecycle (Open/Close/Expunge), descriptor bytes,
  16/16 byte-identical streams, all round-trips; -17 on
  short/incompressible inputs matches the original.
