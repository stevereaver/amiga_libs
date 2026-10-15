---
file: log
---
# Work log

- 2026-10-15: 1-hunk COLDSTART, ELBOX encrypted payload.  Plaintext
  decryptor emitted as mnemonics/.short; resident+strings+InitStruct+
  ciphertext as `.byte`; fixup splices original RELOC32 tail.
  BYTE-IDENTICAL.
- Static decrypt (XOR + rol.l #4, key stream = decryptor bytes then
  already-plaintext, lag 0x90) reproduced; checksum region 0xd0-0xf5f
  sums to 0 as designed.  Payload disassembled: expansion/pci/intuition
  deps, vendor:device table, two 10-vector functabs, 6 codec variants.
- machine68k oracle: emulated MakeLibrary (rel-offset functab +
  InitStruct byte cmds), ConfigDev/FindDevice stubs, fake codec regs.
  init -> Open x2 -> all 10 vectors -> set/get/raw -> Close ->
  dead-code expunge.  RUNTIME-IDENTICAL.
