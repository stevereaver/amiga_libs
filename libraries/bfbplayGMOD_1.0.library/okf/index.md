# bfbplayGMOD.library V1.0

- **Binary**: `binary/bfbplayGMOD_1.0.library` (1844B, single CODE hunk)
- **Identity**: `bfbplayGMOD.library V1.0 (13.06.1996)`
- **Purpose**: GMOD module player — same bfb tag-driven template as
  bfbplayPSID/MED, but the module image IS the player: embedded 68k
  routines are called at fixed buffer offsets (+20 play song, +24 stop,
  +40 per-tick, +64 song count), ticked by a CIA timer ICR interrupt.
- **RomTag**: RTF_AUTOINIT, ver 1, NT_LIBRARY, pri 0
- **InitTable**: dataSize 0xb2 (178), LONG functab, LibInit opens
  `dos.library` (any ver) -> base+40
- **Reconstruction**: `source/` — C (`bfbplayGMOD.c`) + asm skeleton
  (`bfbplayGMOD_lib.s`); header/strings/datatab byte-identical modulo
  relocated pointers; interrupt tail byte-identical.
- **Status**: complete.

## Vectors

| LVO | Name | Notes |
|-----|------|-------|
| -6/-12/-18 | Open/Close/Expunge | standard; Expunge closes dos only |
| -24 | stub | ret 0 |
| -30 | InitModule | TagItem list; loads GMOD via filename/handle/memory; type=7 |
| -36 | EndModule | stop (mod+24) if running, cia_stop, frees modbuf/buf3/session |
| -42 | PlayModule | ensure ciaa+ciab resources (-13 on fail); stop-if-running; mod+20(cursong); cia_start if !playing; running=playing=1 |
| -48 | StopModule | a0=sess; mod+24 if running; running=0 |
| -54/-60/-66 | stubs | ret -1 |
| -72 | SetSubsong | d0=0-based n; clamps (songsm1<n keeps); stores raw at +24; restarts mod+20 if was running |
| -78 | GetInfo | returns 0 |
| -84 | GetDesc | "GMOD module structure by Bryan Ford" |

## InitModule tags

| tag | meaning |
|-----|---------|
| 0x80000007 | session ptr slot (required; ti_Data=0 -> 80B AllocMem MEMF_CLEAR) |
| 0x80000001 | filename (dos Open MODE_OLDFILE) |
| 0x80000002 | already-open handle (d6=ishandle; not closed after read) |
| 0x80000003 | in-memory image (requires 0x80000008 = length; used in place) |

modbuf alloc: MEMF_CHIP|MEMF_CLEAR (0x10002).  Size from
Seek(0,END)+Seek(0,BEGIN) pair — the second Seek's return (old pos) is
the filesize.

## CIA replay path

```
CIA timer underflow (TA or TB, period 0x3781)
  -> cia.resource ICR interrupt  (_icr_intr, is_Code=_cause_tramp)
  -> jsr -180(a6) = exec Cause(inner)
  -> _tick_dispatch (inner is_Code): if cur_sess && sess+1: jsr modbuf+40
```

`cia_start` probes timer A then B on ciaa, then A then B on ciab;
records {cia base, resource, timer#} at base+168/+172/+176, programs
TALO/TAHI or TBLO/TBHI with period 0x3781, starts CRx = 0x11.
`cia_stop` clears CRx and RemICRVector's.

See `functions/vectors.md`, `structures/layout.md`,
`findings/defects.md`, `log.md`.
