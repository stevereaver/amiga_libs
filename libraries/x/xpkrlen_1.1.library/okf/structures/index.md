# Structures

- XpkSubParams / XpkSubBase: xpk sublibrary ABI (see
  ../xpkNONE_1.4.library/okf for the authoritative field map).
- The DATA hunk is a 0x114-byte block: embedded InitTable at +4,
  `$VER:` string, then a 256-byte XpkInfo/XpkMode template copied to
  base+0x3a at init, and a fixup-offset table at +0x100
  (count=4, offsets 0xe2,0xb6,0xb2,0xae).
