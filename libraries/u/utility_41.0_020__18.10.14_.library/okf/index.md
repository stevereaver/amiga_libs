# utility.library 41.0 (020) — OKF Index

`utility 41.0 (18.10.2014)` — compact hand-written utility.library
replacement (THOR/BAH-family style), 68020-optimised.  Single code
hunk, Resident with `RTF_AUTOINIT|RTF_COLDSTART`, priority 103.

Provides 49 vectors (-6 .. -294): lifecycle, the full tag-item API,
clock/date helpers, software 32/64-bit math (patched at init with
native 020 `muls.l/mulu.l/divsl.l/divul.l` stubs when AttnFlags has
020-040 bits; on 68060 only the two 32-bit multiplies are patched),
case-folding string compares, structure pack/unpack, and the named-
object (ANO_*) API.

## Hunks

| hunk | type | size | contents |
|------|------|------|----------|
| 0 | CODE | 2360 | RomTag@0, InitTable@0x1a, word-offset functab@0x2a, all code, strings |

InitTable at code+0x1a: `{dsize=0x30, functab->+0x2a, datatab=0,
initfn->+0xd8}`.  The functab is the word-offset form (`0xffff`
marker, offsets relative to the marker word), 49 entries ending with
`-294` -> lib_NegSize 0x126.

## Private data (lib+36, dataSize 0x30)

| off | use |
|-----|-----|
| +36 | SysBase |
| +40 | default named-object (empty-name, ANO_NameSpace=1) |
| +44 | GetUniqueID counter |

## Documents

- `functions/vectors.md` — all 49 vectors with entry points and notes
- `structures/layout.md` — named-object node/ns layout, pack-table format
- `findings/defects.md` — bugs and behavioural inconsistencies in the original
- `log.md` — reverse-engineering log
