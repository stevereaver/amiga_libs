# Layout

## Hunk structure

| Hunk | Type | Size | Notes |
|------|------|------|-------|
| 0 | CODE | 0x3f8 | all functions + embedded strings/tables/RomTag |
| 1 | DATA | 0x220 | runtime slots, InitTable, registration strings |
| 2 | BSS | 4 | seglist slot |

## Code hunk map

| Off | Contents |
|-----|----------|
| 0x00 | entry stub (returns 30 = RETURN_FAIL) |
| 0x0a | `"dos.library"`, `"intuition.library"`, `"utility.library"` |
| 0x38 | open_deps / close_deps / LibInit / LibOpen / LibExpunge / LibClose / reserved |
| 0x28c | functab (15 absolute longs + `ffffffff`) |
| 0x2cc | **RomTag**: `4afc`, self MatchTag, EndSkip→0x320, flags 0x80 (RTF_COLDSTART), ver 45, type 9 (NT_LIBRARY), pri 0, name→0x30d, idstr→0x2e6, **rt_Init=16** |
| 0x2e6 | `"genesiskey.library 45.3 (20.11.2000)\r\n"` |
| 0x30d | `"genesiskey.library"` |
| 0x320 | `dc.l 0` (EndSkip target) |
| 0x324 | `"genesis.library"`, `"bsdsocket.library"` |
| 0x346 | socket probe, ret-0x20, ret-0x120, 8 empty stubs (8B each) |
| 0x3ee | tail `dc.w 0; dc.l 0; dc.l 3` |

## Data hunk map

| Off | Contents |
|-----|----------|
| +0x00 | exec base slot (written by LibInit) |
| +0x04 | dos.library base |
| +0x08 | intuition.library base |
| +0x0c | utility.library base |
| +0x10 | **InitTable**: `{0x52, functab, NULL, initFn}` = MakeLibrary args |
| +0x20 | `"454545"` — embedded serial (offset returned by vector -66) |
| +0x120 | `"AmigaOS 3.9"` — embedded OS string (offset returned by -78) |
| +0x220 | end |

## Library structure (MakeLibrary dataSize = 0x52)

```
struct Lib (34)        standard Node+Lib; OpenCnt at +32
+34..35  pad
+36..81  SignalSemaphore (46B) — init'd by LibInit
```

Note `lib_Version` stays 0 (no data table supplies it); only
`lib_Revision` is patched to 3 by LibInit — the "45" exists solely in
the RomTag and IdString.

## rt_Init = 16

The RomTag's init field is the literal 16 — the *offset of the
InitTable within the data hunk*.  Standard InitResident cannot use
this; the Genesis loader reads `dataHunk + rt_Init` (or equivalent),
then calls MakeLibrary(funcTab, NULL, initFn, 0x52, seglist).
