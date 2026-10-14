# write_4.2.library — quirks & inconsistencies

1. **Overlapping-instruction idiom** (compiler artifact, SAS/C-era):
   `cmpiw #N,d0` immediate words double as real instructions entered via
   branch — five sites (see log.md). First-time executors run the cmpiw
   as a dead compare; loop/error paths jump into the operand. Requires
   raw `.short` emission to reproduce.

2. **rt_Name quirk**: functab/name idstr live in a separate CODE hunk
   (h1), unusual — most libs keep them in the same hunk as the RomTag.

3. **InitTable padded**: hunk2 starts with a 0 pad long; the InitTable
   proper begins at +4.

4. **idstr generic**: `"Version 1.0"` — does NOT match the RomTag
   version 4.2 nor the embedded `$VER:write.library 4.2 (7.11.95)`
   string in hunk0. Real version banner is in hunk0, not the RomTag
   idstr.

5. **-42 quirk**: `tstl sp@(8)` tests a `lea`-computed address — always
   non-NULL (dead check emitted by the compiler).

6. **A3 arg convention**: -42 takes a3 as an input arg (msg port) — a
   register-arg calling convention mixed with stack args, typical of
   Lattice/SAS C register-params builds.

7. **Duplicate base slots**: rexxsyslib base stored to BOTH a4@(100) and
   a4@(104); dos base to both a4@(108) and a4@(112). Redundant compiler
   output kept verbatim.
