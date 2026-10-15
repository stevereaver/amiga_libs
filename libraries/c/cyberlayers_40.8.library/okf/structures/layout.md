# cyberlayers.library 40.8 — layout

## Hunks

| # | type | body | contents |
|---|------|------|----------|
| 0 | CODE | 0x844 B (0x211 L) | DOS stub + RomTag @+4, strings @+0x1e..0xc1, InitTable @0xc2, word-offset functab @0xd2, datatab @0xde, initfn @0xfe, _initctx @0x152, _patchinstall @0x454, patchtab @0x48c, own vectors @0x4b2-0x51d, CYBL record+SwapBits @0x51e-0x843 |
| 1 | CODE | 0x29c B (0xa7 L)  | five CYBL records @0x00/0x1c/0xd2/0xf6/0x11e + the five patched layers functions + _roverlap @0x26e; rt_EndSkip = +0x29c (EOF) |

Relocation: **HUNK_RELOC32SHORT** (0x3f7) on hunk0 only —
- h0 -> h0 {0x6, 0x12, 0x16, 0x1a, 0xc6, 0xca, 0xce, 0xe4, 0xf6, 0x4ac}
- h0 -> h1 {0xa, 0x48e, 0x494, 0x49a, 0x4a0, 0x4a6}

All code is pc-relative; the only relocated words are RomTag/InitTable/
datatab/patchtab data longs (hence the compact form).

## RomTag (h0+4)

`4afc`, matchtag->h0+4, endskip->h1+0x29c, `80 28 09 00` (AUTOINIT,
ver 40, NT_LIBRARY, pri 0), name->h0+0x1e `"cyberlayers.library"`,
idstr->h0+0x32, init->h0+0xc2.

## InitTable (h0+0xc2) + datatab (h0+0xde)

`{dsize=0x76, functab->0xd2, datatab->0xde, initfn->0xfe}`.

datatab ops: initbyte +8=9 (ln_Type), initlong +10=name, initbyte
+14=6 (ln_Flags LIBF_CHANGED|LIBF_SUMUSED), initword +20=40/+22=8,
initlong +24=idstr.

functab @0xd2 = relative format (`ffff`) + `{0x3e0,0x3ee,0x402,0x448}`
-> 0x4b2/0x4c0/0x4d4/0x51a + `ffff`. NegSize=24, PosSize=0x76.

## cyberlayers library base (dsize 0x76)

| off | field |
|-----|-------|
| 0x00-0x21 | struct Library (via datatab) |
| 34 | SysBase |
| 38 | seglist |
| 42 | layers.library base (OpenLibrary v39) |
| 46 | graphics.library base (v39) |
| 50 | &ExtFunc stub (h0+0x51a) |
| 54 | cybergraphics.library base (v40) — NULL aborts init |
| 58 | SwapBits bitmap cache: 30 x {bitmap@0, buffer@4} — NOTE: spans +58..+298, past the 118-B positive size (see quirks) |

## CYBL record (18 B, preceding each patched function)

| off | field |
|-----|-------|
| +0  | 'CYBL' magic |
| +4  | w: required exec version (0x27 = 39; patchinstall gate) |
| +6  | w: 1 |
| +8  | w: 0 |
| +0xa | l: filled with cyberlayers lib base at install time |
| +0xe | l: filled with the previous vector (tail-call target) |

Records at h1+0x00/0x1c/0xd2/0xf6/0x11e (funcs at +0x12/+0x2e/+0xe4/
+0x108/+0x130) and h0+0x51e (func at +0x530). The patchtab
(h0+0x48c) drives installation: `{-36,h1+0x12},{-186,h1+0x2e},
{-60,h1+0xe4},{-180,h1+0x130},{-66,h1+0x108},{-126,h0+0x530},{0}`.

## Packed Resident view used by _initctx

The copy code treats the layers Resident as a packed 26-byte struct:
`+0 matchword, +2 matchtag, +6 endskip, +8 fl/v/t/p, +14 name,
+18 idstr, +22 init` — plus pointers at init+4/+8/+12/+40 rewritten
into copy-relative form (InitTable fields + an interior pointer).

## Foreign structures touched

- **struct Layer (internal CGX-era layout)**: +0 front, +8 ClipRect,
  +12 rp (RastPort*), +16-22 bounds {MinX,MinY,MaxX,MaxY}, +30 Flags
  (u16; type bits at low byte +31: SIMPLE=1/SMART=2/SUPER=4;
  mask 0x680 cleared by CUHL), +68 LayerInfo*, +118 backfill hook
  (LAYERS_NOBACKFILL = (Hook*)1 sentinel), +156 ClipRegion*.
- **struct ClipRect**: +0 Next, +8 lobs (non-zero = obscured clip),
  +16-22 bounds.
- **struct ClipRect (SwapBits arg)**: +12 BitMap*, +16-22 bounds.
- **struct BitMap (CGX-extended)**: +1 bit0 "native/chunky" flag,
  +36 'CYBR' magic when CGX-managed.
- **struct RastPort**: +4 BitMap*.
- **exec**: version@+20, AttnFlags@+297 (bit3 = 68020 gate for the
  non-CYBR native path).
