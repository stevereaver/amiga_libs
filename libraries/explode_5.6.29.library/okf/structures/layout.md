# explode.library layout

## File

- 1 code hunk (0x17B longs = 0x5EC bytes), 19 RELOC32 entries.
- RomTag @4 AUTOINIT v5 pri0; endskip 0x5EC (hunk end).

## Hunk map (original)

| Off | Contents |
|----:|----------|
| 0x000 | `moveq #-1,d0;rts` pre-tag stub |
| 0x004 | Resident tag |
| 0x01e | "explode.library" |
| 0x02e | idstr "Executable Explode Wedge V5.6.29 (16-Jul-91 00:21:38)\r\n" |
| 0x066 | "dos.library" |
| 0x072 | INIT: size=0x32, functab=0x82, datatab=0x9E, init=0xCA |
| 0x082 | LONG functab (6+term) |
| 0x09e | datatab — 24-bit-offset InitStruct form (E0/C0/D0 opcodes) |
| 0x0ca | LibInit (wedge install) |
| 0x168 | LibOpen |
| 0x176 | LibClose -> shared expunge @0x188 |
| 0x184 | ret0 stub (vectors -18,-24) |
| 0x188 | expunge body |
| 0x1ee | -36 mark |
| 0x1f6 | `_ExpStub` installable wedge (`moveq#0;jsr $0` + sig check) |
| 0x25a | -30 Explode trampoline |
| 0x28c | decoder setup + outer loop |
| 0x39a | `_exp_rdlong` |
| 0x3a4 | `_exp_copy` |
| 0x3de | `_exp_rewind` decoder coroutine |
| 0x53a | `_exp_tail` surplus-hunk FreeMem |
| 0x55c | `_exp_hunkwalk` |
| 0x574 | tab1 (12B: class bases/bits) |
| 0x580 | tab2 (9 x 12B records, indexed by header lo-nibble) |

## Packed-segment conventions

- a5 = control block at `seg_hunk0 + 32`; magic "explode.library" at
  its offset +8 (hunk+40).
- Bit stream stored backwards ending inside hunk[count-2].
- Ring = last hunk's data area; decompressed hunks written forward
  from each hunk's data start.
- Relocation fixups interleaved in the control stream (delta offsets,
  add hunk base).
