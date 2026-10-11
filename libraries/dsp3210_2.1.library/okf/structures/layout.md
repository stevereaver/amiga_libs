# dsp3210.library — structures

## DSPBase (dataSize 46)

| off | field |
|-----|-------|
| 0-33 | struct Library (34B) |
| 34   | seglist (BPTR, set by libInit) |
| 38   | unused |
| 42   | dosbase — lazy OpenLibrary("dos.library",36), cleared+closed on expunge |

## COFF file header (big-endian)

| off | field |
|-----|-------|
| 0   | f_magic (w) = 0x166 |
| 2   | f_nscns (w) |
| 4   | f_timdat (l) |
| 8   | f_symptr (l) — byte offset to symbol table |
| 12  | f_nsyms (l) — 18-byte entries |
| 16  | f_opthdr (w) — optional header size |
| 18  | f_flags (w) — bit 0x02 (F_EXEC) shifts reloc write base +4 |

Section table at `img+20+f_opthdr`, 40-byte entries:

| off | field |
|-----|-------|
| 0   | s_name[8] |
| 8   | s_paddr (l) |
| 12  | s_vaddr (l) |
| 16  | s_size (l) |
| 20  | s_scnptr (l) — file offset of raw data |
| 24  | s_relptr (l) — file offset of relocs |
| 28  | s_lnnoptr (l) — assumed 0 (nreloc read as BE long @30) |
| 32  | s_nreloc (w) |
| 34  | s_nlnno (w) |
| 36  | s_flags (l) — 0x20 TEXT / 0x40 DATA / 0x80 BSS |

Symbol entry (18B): n_name/n_zeroes+n_offset (8), n_value@8 (l),
n_scnum@12 (w, signed: 0=UNDEF, <0 error, else 1-based section),
n_type@14 (w), n_sclass@16 (b), n_numaux@17 (b).

Reloc entry (10B): r_vaddr@0 (l), r_symndx@4 (l), r_type@8 (w).

String table follows symtab at `img+f_symptr+f_nsyms*18`.

## Loaded descriptor (dsp_loadfile, dsp_unload)

| off | field |
|-----|-------|
| 0   | magic 0x32102011 |
| 4   | image size N |
| 8   | loaded/relocated image (N bytes) — returned pointer |

## Host export table (exttab, stack arg to -36)

8-byte entries {char *name, void *value}; NULL name terminates.
Matches UNDEF symbol names to host addresses verbatim (no section
adjustment).
