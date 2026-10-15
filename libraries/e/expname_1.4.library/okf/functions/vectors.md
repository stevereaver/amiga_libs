# Vectors (expname.library 1.4)

Absolute-long functab at code+0xba, `-1` terminated.  Five vectors:

| LVO | code | name     | semantics |
|-----|------|----------|-----------|
| -6  | 0x112 | Open    | openCnt(+0x20)++, clears flag(+0x23) bit0, returns a6 |
| -12 | 0x120 | Close   | openCnt--; at 0 with flag bit0 set -> tail-calls Expunge; returns 0 |
| -18 | 0x134 | Expunge | openCnt!=0 -> sets flag bit0 (deferred), returns 0; else Remove()s via stored ExecBase(+0x24), FreeMem(lib-negsize, neg+pos) via abs-4, returns seglist(+0x28) in d0 |
| -24 | 0x17c | (null)  | `moveq #0,d0; rts` |
| -30 | 0x1ac | ExName  | the name-lookup entry point |

## ExName(boardOrNull, mfr, prod, mfrbuf, prodbuf)

Register args (not stack): `a0`=mfrbuf, `a1`=prodbuf (caller-supplied
NUL-terminated output buffers), `a2`=ExpansionRom/ConfigDev-style board
pointer **or NULL**, `d0`=manufacturer id (word), `d1`=product id (byte).

- `a2 != NULL`: `d6 = (word) board[20]` (er_Manufacturer),
  `d7 = (byte) board[17]` (er_Product); d0/d1 ignored.
- `a2 == NULL`: `d6 = (word) d0`, `d7 = (byte) d1`.

Walks the sorted 12-byte manufacturer table `{long id, char *name,
ProdTab *prods}` (sentinel id = -1).  On `id > mfr` it early-exits
(tables are sorted ascending).  On match, copies the NUL-terminated
manufacturer name to `mfrbuf`, then walks the product table
`{long id, char *name}` for `d7` with the same sorted early-exit.

- Both resolved: returns **-1** (d0).
- Manufacturer unknown: formats `#%ld` into `mfrbuf` via RawDoFmt.
- Product unknown (or mfr unknown): formats `#%ld` into `prodbuf`.
- Any lookup failure returns **0** (even when the manufacturer name
  itself resolved).

Helper `_fmtnum` (code+0x180): wraps RawDoFmt("#%ld", &num, putchar)
with a private putchar stub (`moveb d0,(a3)+`) at code+0x1a2.

## Data area (posSize 0x2c)

| off | field |
|-----|-------|
| +0x20 | openCnt (word) |
| +0x23 | flag byte, bit0 = deferred expunge |
| +0x24 | ExecBase (saved a6 at init) |
| +0x28 | seglist (saved a0 at init) |

## Datatab (InitTable @ code+0xaa)

    dataSize 0x2c, functab->0xba, datatab->0xd2, init->0xf2
    INITBYTE  +0x08 = 9          (ln_Type = NT_LIBRARY)
    INITLONG  +0x0a = libname
    INITBYTE  +0x0e = 6          (lib_Flags = LIBF_CHANGED|LIBF_SUMUSED)
    INITWORD  +0x14 = 1          (lib_Version)
    INITWORD  +0x16 = 4          (lib_Revision)
    INITLONG  +0x18 = idstr

LibInit (code+0xf2): `moveml d1-a6,-(sp)`, stores libbase into the
absolute cell at code+0x8b2 (self-referencing long in the code hunk),
a6 -> libbase+0x24, a0 -> libbase+0x28, returns libbase.  A dead
two-instruction stub (`moveq #0,d0; bra.s` into init's tail) sits at
code+0x10e.
