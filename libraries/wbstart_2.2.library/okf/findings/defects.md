---
file: defects
---
# Findings

- Non-AUTOINIT resident (rt_Flags=0): rt_Init -> initfn which
  self-installs via MakeLibrary(-84)+AddLibrary(-396).  Init
  bails out entirely when exec `lib_Version` < 39 (returns 0,
  nothing installed).
- DATA hunk mismatch: hunk table allocates 0xa longs (40B) but
  the HUNK_DATA body defines only 1 long; +4..+39 are
  uninitialized globals (SysBase, DOSBase, IconBase,
  UtilityBase, pool, dospathbase, path list, saved
  cli_CommandDir).  Reproduced verbatim by patching the size
  word in fixup.py.
- SAS/C small-data model: every function reloads
  `lea DATA+0x7ffe,a4` and reaches globals through negative
  a4 displacements; a6 is swapped between lib base and the
  target OS base with `exg dn,a6` around every LVO call.
- RELOC32 group offsets are stored non-sorted in the shipped
  binary (group0 starts {5c,58,64,...}); fixup.py verifies the
  (hunk,offset) sets then splices the shipped tail.
- Expunge protocol: when the handler process is alive
  (lib+34!=0) Expunge only signals it (0x1000) and sets
  LIBF_DELEXP; the handler tears itself down and clears lib+34,
  after which a Close/retry performs Remove+FreeMem.
- Handler exit path executes exec Forbid(-132) without a
  matching Permit before returning — the process leaves the
  system forbidden (inherited SAS/C/a6-swap cleanup bug).
- WBStart return convention: 0 = success, 20 = RETURN_FAIL,
  opposite sign vs intuition's BOOL style.
- dospath.library v1 is optional: OpenLibrary failure just
  skips the cli_CommandDir replacement (DATA+24==0 path).
- Tail of the code hunk holds four dead `moveq #0/#1,d0;rts`
  stubs and nop/rts padding — likely linker fill or leftover
  SAS/C glue.
