# Rebuild delta

Rebuilt via m68k-amigaos-gcc -m68000, `-nostdlib -nostartfiles`.

## Matches the shipped layout

- Two hunks: CODE + DATA; the XpkMode/XpkInfo descriptors live in
  the data hunk at +0x00/+0x2a and their string pointers relocate
  into the code hunk — same relocation pattern (21 code-hunk
  relocs + 1 code→data reloc for the PackerInfo descriptor
  pointer).
- AUTOINIT RomTag, ver 1 / rev 3, RTF_AUTOINIT, NT_LIBRARY.
- Absolute-longword function table, 10 vectors + -1.
- dataSize 0x22 (bare struct Library); seglist held in a
  code-space slot.
- Same idstring `xpkRLEN 1.3 (01.04.1997)\r\n` (no `$VER:` tag).

## Differences

- C-compiled framework/codec is larger than the shipped hand asm
  (hunk0 0x308 vs 0x2a0 bytes); instruction selection differs.
- The two `moveq #0,d0;rts` null stubs of the original collapse
  to one C `LibNull`; the dead user-init/cleanup `bsr` hooks in
  LibInit/LibExpunge are not reproduced (semantically void).
- PackerInfo returns the descriptor via `movel #xpkinfo,d0`
  instead of `lea (abs),a0; movel a0,d0` — same value, same
  relocation.
- The `cmpiw`-hidden-instruction trick in the encoder is expressed
  in plain C; emitted streams are identical.
- LibExpunge's pc-relative seglist read becomes an absolute
  reference to `_segslot` — one extra code-hunk relocation.

## Verified

- Codec round-trip: 40k + 20k randomized inputs + all-constant
  edge cases — 0 mismatches; expanding inputs correctly return
  XPKERR_EXPANSION (-17).
- Functab order and all 10 LVOs verified against the fd layout.
