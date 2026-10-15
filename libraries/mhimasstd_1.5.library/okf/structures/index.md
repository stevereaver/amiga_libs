# Structures

- InitTable dataSize 0x2e.
- Handle layout (decoded from init writes): +8 task, +12 sigmask,
  +16 byte flag=1, +18 volume=100, +19..+24 params=50 each; a
  0x10000-byte data ring follows the header.
- BSS globals: DOSBase, MhiBase, owner, MiscBase, GFXBase,
  _BufList (queued 20B nodes), _mhiallocated latch.
