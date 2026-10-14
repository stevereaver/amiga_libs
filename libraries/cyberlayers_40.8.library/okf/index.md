# cyberlayers.library 40.8 -- OKF index

- **File**: `binary/cyberlayers_40.8.library` (2884 bytes, 2 hunks)
- **ID string**: `cyberlayers.library 40.8 (02.01.96) \xa9 by Vision Factory Development\r\n`
- **Vendor**: Vision Factory Development (CyberGraphX ecosystem)
- **Kind**: AUTOINIT library, version 40, revision 8, NT_LIBRARY, pri 0
- **Reconstruction**: `source/` -- byte-exact assembly transcription
  (`cyberlayers_h0.s`, `cyberlayers_h1.s`, hand-written
  mnemonic assembly preserving the mid-instruction pointers and
  overlapped encodings). `make` in `source/` rebuilds
  `cyberlayers.library`; `fixup.py` rewrites the relocation tail to
  the original nonstandard `0x3f7` format.
- **Build verified**: `cmp` byte-identical, MD5
  `51ee1a5be1b9c2af4cf7740c3b91d591`
- **Runtime verified**: `work/oracle.py` (machine68k) -- original and
  rebuild produce identical logs over init (resident clone + vector
  redirection + CYBL install), lifecycle vectors, and calls into all
  six installed CYBL patch routines.

## What this library is

A *library cloner + vector redirector* for `layers.library`, part of
the CyberGraphX graphics-retargeting system. On init it:

1. Opens `layers.library` (v39), `graphics.library` (v39) and
   `cybergraphics.library` (v40; failure aborts init).
2. `FindResident("layers.library")`, allocates `rt_EndSkip-rt` bytes
   (AllocVec), CopyMem's the resident, rebases its internal pointers
   (MatchTag, EndSkip, Name->`layersdummy.library`, IdString, Init and
   the InitTable functab/datatab/initfn/+0x28 fields) onto the copy,
   then `InitResident`s it -- registering a second library named
   `layersdummy.library` whose vectors land inside the RAM copy.
3. Scans the clone for `jmp pc@(d16)` instructions (0x4eba) targeting
   the clone's -126 vector and rewrites them to `jsr a6@(-126)`, then
   CacheClearU, Forbid, and 33x `SetFunction` on the *real*
   layers.library, repointing every vector -30..-216 at the clone's
   functions, then Permit + CloseLibrary.
4. Installs six `CYBL` replacement routines over the real
   layers.library vectors -36, -186, -60, -180, -66, -126. Each CYBL
   block carries a minimum-exec-version word; blocks requiring more
   than `SysBase->LibNode.lib_Version` abort the whole install.

Net effect: layers.library runs CyberGraphX-aware replacement code in
RAM while `layersdummy.library` holds a pristine copy.
