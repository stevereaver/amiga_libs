# genesiskey.library 45.3 — OKF index

- **File**: `libraries/genesiskey_45.3.library/binary/genesiskey_45.3.library` (1908 B)
- **IdString**: `genesiskey.library 45.3 (20.11.2000)\r\n`
- **Role**: generated registration/key library for the **Genesis TCP/IP
  stack** (the commercial stack; requires `genesis.library` v3 and
  `bsdsocket.library` v4).  Stores an embedded serial/OS pair and acts
  as a presence probe.
- **Format**: three-hunk Amiga hunk file — code 0x3f8, data 0x220,
  bss 4.  **No standard resident-init flow**: RomTag is embedded
  mid-code but `rt_Init` = 16 = *data-hunk offset* of a MakeLibrary
  InitTable; a custom loader (inside the Genesis package) builds the
  library.
- **Reconstruction**: `source/` — `genesiskey.c` (all logic),
  `genesiskey_lib.s` (entry stub, code-resident strings, absolute
  functab, RomTag, data hunk layout), `endmodule.s` (tail longs).

## Bundle

| File | Contents |
|------|----------|
| `functions/vectors.md` | Functab layout, LVO map, per-vector semantics |
| `structures/layout.md` | Hunk layout, library struct, data-hunk map, InitTable, RomTag |
| `findings/defects.md` | Quirks and anomalies in the shipped binary |
| `log.md` | Work log |
