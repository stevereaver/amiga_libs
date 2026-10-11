# xpkZENO 1.2 — library vectors

AUTOINIT library (`RTF_AUTOINIT`), word-offset function table.
Original code hunk: 0x688 bytes, 19 HUNK_RELOC32 entries.

## Vector map

| LVO  | Entry            | Notes                                    |
|------|------------------|------------------------------------------|
| -6   | LibOpen          | `++OpenCnt; clear DELEXP; return base`   |
| -12  | LibClose         | `--OpenCnt; expunge if DELEXP`           |
| -18  | LibExpunge       | expunge when OpenCnt==0, else DELEXP     |
| -24  | `_start`         | shared `moveq #0,d0; rts` stub (hunk+0)  |
| -30  | XpksPackerInfo   | returns `xpkinfo` APTR                   |
| -36  | XpksPackChunk    | LZW packer                               |
| -42  | XpksPackFree     | frees pack workmem (shared routine)      |
| -48  | `_start`         | PackReset — no-op via entry stub         |
| -54  | XpksUnpackChunk  | LZW unpacker                             |
| -60  | XpksUnpackFree   | shares the PackFree routine              |

-24/-48 emit a negative word offset that wraps the functab base
back to hunk+0 (the EndSkip `moveq #0,d0; rts`).  -42/-60 share
one free routine that reads the allocation long at `xsp_Sub[0]-4`.

## Resident structure (hunk offsets)

| off   | contents                                        |
|-------|-------------------------------------------------|
| 0x000 | EndSkip stub `moveq #0,d0; rts`                 |
| 0x004 | RomTag `0x4afc`, EndSkip->+0, AUTOINIT, ver 1   |
| 0x01e | `"xpkZENO.library"`                             |
| 0x02e | `"$VER: xpkZENO V1.2 (1 Oct 2013) by Gerhard Tuenkler"` |
| 0x064 | init table: dataSize 0x26, functab, datatab, init |
| 0x074 | data table (ln_Type 9, ln_Name, flags 6, ver 1/0, idstr) |
| 0x094 | function table: `-1` marker + 10 word offsets   |
| 0x0ac | LibInit — stores seglist at lib+34              |
| 0x56a | XpkInfo descriptor, mode chain, strings         |

Reconstruction: `source/xpkZENO.library` is a single-code-hunk
HUNK (0xf00 code) — GCC codegen is bulkier than the original,
but the resident header through 0x62 and the descriptor region
are byte-identical modulo relocated pointers.
