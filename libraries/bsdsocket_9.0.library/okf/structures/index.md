# Structures

- InitTable dataSize 0xf6 (large private base: engine obj +0x26,
  errno slot ~+0x3a, transaction semaphore +0x46).
- Shared wire-message block in BSS (SECSTRT_2, ~256B): byte0=opcode,
  args packed big-endian-ish; replies overwrite the block.
