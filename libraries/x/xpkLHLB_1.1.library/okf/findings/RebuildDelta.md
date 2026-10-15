# Rebuild delta

Rebuilt via m68k-amigaos-gcc -m68000, `-nostdlib -nostartfiles`.

## Matches the shipped layout

- Single code hunk; entry `moveq #-1,d0;rts` + `moveq #0,d0;rts`
  null stub; AUTOINIT RomTag ver 1; absolute-longword functab
  (10 vectors + -1); dataSize 0x30; idstring incl. the "LBLB"
  typo; code-resident XpkInfo/XpkMode with the same field values.

## Differences

- C-compiled framework is larger than the shipped asm (hunk
  0x398 vs 0x364 bytes); instruction selection differs.
- The unpack error test is `ret == 0 -> -14` in C vs the
  original's CCR-Z `seq` test (equivalent under lh's flag
  convention; documented in the function page).
- `cmpa.w #0` 16-bit NULL checks become full-width `!ptr` tests
  in C (documented quirk).
- XpkFree returns 0; the original returns whatever d0 held after
  lh -36 (callers ignore it).

## Verified

- Functab order, all 10 LVOs, exec/lh call offsets (-552, -414,
  -252, -210, -198, -624, -30, -36, -42, -48) checked in the
  compiled code.
- Cannot be codec-tested on the host: it is a pure adapter and
  requires a running lh.library.
