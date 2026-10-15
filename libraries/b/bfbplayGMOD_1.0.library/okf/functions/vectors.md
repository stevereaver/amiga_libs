# Vectors — bfbplayGMOD.library V1.0

LONG functab, 14 vectors + `ffff ffff`.  a6 = library base throughout.

| LVO | Sym | Args | Returns |
|-----|-----|------|---------|
| -6  | LibOpen | a6=base | base; clears flag+34 bit3 |
| -12 | LibClose | a6=base | 0; expunges on 0+dexp |
| -18 | LibExpunge | a6=base | seglist or 0; Remove+CloseLibrary(dos)+FreeMem |
| -24 | LibNull | — | 0 |
| -30 | InitModule | a0=tags | 0 ok / -6,-7,-8,-13,-17 |
| -36 | EndModule | a0=sess | 0 (also clears code-hunk cur_sess) |
| -42 | PlayModule | a0=sess | 0 / -13 |
| -48 | StopModule | a0=sess | (void-ish; d0 unpreserved structurally) |
| -54 | — | — | -1 |
| -60 | — | — | -1 |
| -66 | — | — | -1 |
| -72 | SetSubsong | a0=sess, d0=n | cursong (clamped 0-based) |
| -78 | GetInfo | a0=sess | 0 |
| -84 | GetDesc | — | "GMOD module structure by Bryan Ford" |

## Embedded module jump table (GMOD image, a0 = modbuf)

| offset | role |
|--------|------|
| +20 | play song d0 (0-based cursong passed) |
| +24 | stop |
| +40 | per-tick replay (called from CIA softint) |
| +64 | return song count in d0 (called with d0=1) |

## CIA helpers (internal)

- `ensure_resources` (LAB_0044): OpenResource("ciaa.resource") ->
  base+160; patches the string to "ciab.resource" in place ->
  base+164.  -1 on either failure.
- `cia_start` (LAB_004A): cia_stop first; period word base+158 =
  0x3781; probe ciaa timer A, B then ciab timer A, B via
  AddICRVector(-6); writes TALO(+0x400)/TAHI(+0x500) or
  TBLO(+0x600)/TBHI(+0x700); CRx(+0xe00/0xf00) = 0x11.
- `cia_stop` (LAB_004F): CRx = 0, RemICRVector(-12), clears
  base+168/+176.
