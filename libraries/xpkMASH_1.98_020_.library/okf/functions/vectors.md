# xpkMASH.library 1.98 (020) — vectors and LVOs

Function table: absolute-long entries at code offset covered by RELOC32;
InitStruct datatab writes the standard Library header fields.

| LVO | entry | behavior |
|-----|-------|----------|
| -6  | `_LibOpen`    | opencnt++ (lib+32), `bclr #3` DELEXP (lib+14), return lib |
| -12 | `_LibClose`   | opencnt--; if 0 and DELEXP set → Expunge; returns 0/expunge-result |
| -18 | `_Expunge`    | if open: `bset #3` DELEXP, return 0; else `Remove(lib)` + `FreeMem`, return seglist (lib+38) |
| -24 | `_ret0a`      | `moveq #0,d0; rts` |
| -30 | `XpksPackerInfo` | a0 ← sublibrary info block in code hunk |
| -36 | `XpksPackChunk`  | compress; xsp param block in a0 (see structures) |
| -42 | `_ret0b`      | `moveq #0,d0; rts` (unused) |
| -48 | `_ret0b`      | same |
| -54 | `XpksUnpackChunk`| decompress; same xsp block |
| -60 | `_ret0b`      | same |

## Sublibrary info block (XpksPackerInfo target)

`short=Mashiner`, `long="MASH.020 V1.98, good packer"`,
`desc="WindowSize: 32KB, 2 mixed streams  Dynamic Buffer Allocation"`,
id `'MASH'`, flags `0x8009`, max/min/def packed chunk `0x7ffff/0x28/0x10000`,
verbs `Mashing/UnMashing/Mashed/UnMashed`, def mode 100, one mode record.

## External calls

exec only: `AllocMem` (-198), `FreeMem` (-210), `Remove` (-252).
No cache calls in this build.

## Packer behavior (observed)

- mode 100 and mode 0 produce identical streams (mode unused by MASH).
- Inputs n<4 return rc=-17 with `OutLen` left unwritten (see defects).
- Packer allocates ~131 KB + 2·n work memory, frees it before return.
- Unpacker (`XpksUnpackChunk`) round-trips all oracle cases byte-exact.
