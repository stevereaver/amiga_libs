# bfbplayWHIT.library V1.0

- **Binary**: `binary/bfbplayWHIT_1.0.library` (2128 bytes, single
  CODE hunk of 1948B, 32 relocations, HUNK_END; standard AUTOINIT)
- **Identity**: `bfbplayWHIT.library V1.0 (13.06.1996)`
- **Purpose**: David Whittaker module player in the bfbplay tag-
  driven template (same family as bfbplayGMOD/PSID/MED).  The loaded
  module image is embedded 68k code called at fixed offsets:
    +0  play subsong (d0 = index)
    +14 per-tick replay (driven by CIA ICR -> Cause -> softint)
    +28 stop
    +42 continue/resume
  GetDesc: "Whittaker moduletype probably by David Whittaker.\n
  New CIA routines by K-P Koljonen, adapted by\nJarkko Vatjus-
  Anttila.\n"  A dead "David Whittaker" string sits at code+0x76
  (format-name remnant; WHIT stores ULONG 0x74 at sess+26 instead).
- **RomTag**: packed (MatchTag at +2), RTF_AUTOINIT, ver 1,
  NT_LIBRARY, pri 0.
- **InitTable**: dataSize 0xb2 (178), LONG functab (14 vectors),
  datatab identical to bfbplayGMOD's (type 9 / name / flags 6 /
  ver 1 rev 0 / idstring), initRoutine = LibInit.
- **Dependencies**: dos.library (any ver) -> base+40 at LibInit;
  ciaa.resource + ciab.resource lazily opened by the first
  PlayModule (name patched in place 'a'->'b'); timer name
  "BFBPlay CIA timer.".
- **Reconstruction**: `source/` -- C (`bfbplayWHIT.c`) + asm
  skeleton (`bfbplayWHIT_lib.s`); single-hunk AUTOINIT.
  Verified under a Musashi oracle (`work/whit_test.py`): identical
  init, InitModule file/handle/memory paths, detector result,
  Play/Stop/Cont/SetSubsong call sequences, CIA alloc and the full
  Cause->softint->modbuf+14 tick chain.
- **Status**: complete.  Plane: AMIGALIBS-100.

## Vectors (14 x long, code+0x10a)

| LVO | code | name |
|-----|------|------|
| -6  | 0x198 | LibOpen |
| -12 | 0x1a6 | LibClose |
| -18 | 0x1ba | LibExpunge |
| -24 | 0x200 | ret 0 |
| -30 | 0x22a | InitModule(tags) |
| -36 | 0x3f6 | EndModule(sess) |
| -42 | 0x44a | PlayModule(sess) |
| -48 | 0x4a6 | StopModule(sess)  (internal stop helper too) |
| -54 | 0x4d4 | ContModule(sess)  (resume: modbuf+42) |
| -60 | 0x504 | stub ret -1 |
| -66 | 0x510 | stub ret -1 |
| -72 | 0x51c | SetSubsong(sess, d0=n) |
| -78 | 0x558 | GetInfo -> 0 |
| -84 | 0x564 | GetDesc |

## Notes vs the GMOD sibling

- type byte 8 (GMOD: 7); sess+26 is ULONG 0x74 not a name ptr.
- modbuf entry offsets differ: +0 play / +14 tick / +28 stop /
  +42 resume (GMOD: +20 play / +24 stop / +40 tick / +64 songs).
- subsong count comes from `whit_detect` (code signature scan),
  not a modbuf+64 routine.
- `+46` stopped byte is live (ContModule's gate); GMOD padded it.
- EndModule does NOT clear cur_sess -> dangling global (defect).
- PlayModule order: cia_start BEFORE modbuf+0 (GMOD: after).
- OpenResource(-498) and OpenLibrary(-552) go via `moveal 4` --
  the SysBase pointer load.  Rebuilt macro must dereference abs 4
  (`*(ExecBase**)4`), not pass constant 4.
