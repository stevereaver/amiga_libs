# rexxapp (Jan 91).library — OKF

"dissidents" ARexx host-application support library, Jan 1991.
1568-byte file: header declares **two** hunks — hunk0 = CODE
(0x588 body + DREL16 x21), hunk1 = empty CODE (0 bytes).  Byte-
identical reconstruction in `source/rexxapp.s` (MD5
1724406df58c813c7db58aef2ff35320).

- RomTag at code+4: **non-AUTOINIT** (rt_Flags=0), NT_LIBRARY, ver 0.
  rt_Init at code+0x9c calls exec `MakeLibrary` itself, storing the
  caller's a0 into code+0x94 (seglist slot) and a6 into code+0x98
  (SysBase slot) — singleton globals living in the code hunk.
- a1 = library-image template at code+0x72 (NegSize=0x54, PosSize=0x3a,
  lib_Flags=6, ln_Name/`rexxapp.library` and idstr pointers).
- Vectors = 14 absolute `jmp` entries at code+0x1e → LVOs -84..-6
  (entry i lands at LVO -(84-6i)).
- Function API is register-arg: public vectors take a context
  pointer in **a5** (the port/context block lives at a5+0..62;
  MsgPort at a5+0, sigbit +15, sigtask +16, msglist +20, shutdown
  flag +32.hi, msg count +33, port-name ptr +10, rexxsyslib base +42,
  client fns +46/+50, signal mask +54, cmd table +62).

See: functions/vectors.md, structures/layout.md, findings/quirks.md.
