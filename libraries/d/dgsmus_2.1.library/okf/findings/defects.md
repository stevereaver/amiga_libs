---
file: defects
---
# Findings / quirks

- rt_Flags is 0x80 (RTF_COLDSTART) only, yet rt_Init points
  at a MakeLibrary-style InitTable rather than code — the
  AUTOINIT-table convention shared by the other Optonica/
  xpk-era libraries in this repo; a strictly flag-driven
  InitResident would execute the table (it decodes as a run
  of `ori.b` ops terminating in an F-line word at the -1
  functab marker).
- InitStruct first command ($a00c) writes byte 9
  (NT_LIBRARY) at lib+0x0c — the middle of the ln_Name
  pointer field — and is immediately overwritten by the
  following $800a ln_Name long write.  Dead store, likely a
  hand-built table where ln_Type was intended at +8.
  ln_Type itself is left to MakeLibrary's default.
- Hunk 2 is DATA with MEMF_CHIP (flag in both hunk-table
  size entry 0x4000003e and record tag 0x400003ea): a
  248-byte block of alternating 0x7f/0x80 longwords — a
  square-wave fallback waveform for Paula.
- Cross-hunk RELOC32 on hunk 0 only: 31 self slots, 39
  slots into hunk1 (the globals area — mostly the six
  sublib base slots data+0..0x18 plus table refs), 1 slot
  into hunk2 (code+0x62e: `move.l #SECSTRT_2,384(a4)`).
  No DREL16, no SYMBOL, no BSS.
- Open() hard-requires five Optonica sub-libraries plus
  graphics/dos at every first open; failure of any one
  unwinds all and the open returns 0.
- Vector -114 is not meant to be called directly: it is the
  player-task entry installed by exec AddTask from -84
  (via -120).  Calling it standalone is harmless (iterates
  zero channels, unwinds via -90/LIBFUNC_10).
- The -30 dispatcher consumes a -1-terminated longword
  command list in D0 (not a normal arg ABI); unknown
  commands are silently skipped.
