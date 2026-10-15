# structures / layout

## Hunk map (original, single hunk, 1,592 bytes)
- 0x00  `moveq #0,d0; rts` -- shared null-stub target
- 0x04  RomTag RTC_MATCHWORD, AUTOINIT|ver1|NT_LIBRARY
- 0x1e  "xpkLZW5.library"
- 0x2e  "$VER: xpkLZW5 V5.3 (1 Oct 2013) by Niels Froehling"
- 0x64  InitTable (dataSize 0x26)
- 0x74  datatab (InitStruct stream)
- 0x94  functab (-1 marker, 10 word offsets, -1)
- 0xac  LibInit (seglist store + AFB_68020 gate)
- 0xc2  Open / 0xd0 Close / 0xe2 Expunge
- 0x120 XpksPackFree / 0x138 XpksPackReset
- 0x18c XpksPackerInfo / 0x194 XpksPackChunk
- 0x3b8 XpksUnpackChunk
- 0x468 XpkInfo (64B) + 3x XpkMode + name/string pool
- 0x5xx mode names: "cremation" "ashes" "oblivion";
  "LZ-Speeder" "LZ-Welsh (not Welch) 020+ V5.3"
  "Very Similar to TDCS" "Annihilate" "Reanimate"
  "Oh god, It is done!" "Hehe, fast hew."

## Library base (PosSize 0x26)
- +0x00 struct Library (34 bytes)
- +0x22 BPTR seglist (patched by LibInit)

## Workmem (0x80004 bytes, lazily AllocMem'd)
- buf+0  ULONG alloc size (0x80004)
- sub+0       head[65536] ULONG -- newest position per hash key
- sub+0x40000 chain[65536] ULONG -- prev position, pos&0xffff ring
- PackReset underflows 20,164 bytes BELOW sub+0 (defect #1)

## XpkInfo descriptor (verified byte-exact)
- ver 1, lib 5, master 2, modes 0
- ID 'LZW5', flags 0x8009, max 0x7fffffff, def 0x50000, min 0
- DefMode 50 -> "ashes"
- modes (xm_Upto / xm_PackMemory / xm_PackSpeed / xm_UnpackSpeed /
  xm_Ratio):  cremation 33/0x80004/18/545/395
              ashes     67/0x80004/8/545/408
              oblivion 100/0x80004/6/545/412
