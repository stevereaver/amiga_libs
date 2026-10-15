# Work log

- Parsed 3-hunk file: hunk0 code (0x360), hunk1 InitTable
  (0x20), hunk2 functab+strings (0x74); cross-hunk RELOC32
  in {count,dest,offs[]} form
- RomTag name->hunk2+0x18, idstr->hunk2+0x2c, init->hunk1+4
- InitTable@hunk1+4: dataSize 0x58, functab->hunk2+0,
  datatab NULL, initFunc->hunk0+0x20
- Decoded LibInit: SAS/C runtime init -- seglist@+0x22,
  ln_Type/name/flags/version/rev/idstr fields, 28-byte copy of
  the InitTable to base+0x3c, optional {count,offsets} fixup
  buffer alloc (empty in this build: hunk1+0x1c=0)
- Decoded LibOpen: allocates a full private copy (30-byte
  jump-table prefix + 88-byte base), applies fixup table,
  calls per-open init @0x2d0, CacheClearU if exec>=36
- Decoded per-open init @0x2d0: OpenLibrary("intuition.library")
  stored in data+0x14; ignores failure (returns 0 always)
- Decoded per-open cleanup @0x314: CloseLibrary if non-NULL
- Decoded public vector @0x33c: DisplayBeep(NULL) via
  intuition -96; no NULL check on the base
- C reconstruction: single-base model; Open opens intuition,
  Close closes it, -30 calls DisplayBeep -- same observable
  semantics without the SAS/C copy machinery
- Built clean; verified RomTag/functab/all 5 jsr LVO offsets
