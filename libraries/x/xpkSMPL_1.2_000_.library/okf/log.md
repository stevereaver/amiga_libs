# xpkSMPL 1.2 work log

- extracted single code hunk (0x620 bytes) from 1688-byte library
- IRA disasm; vector map resolved (std -6/-12/-18, null -24/-48,
  -30 info, -36 pack, -42/-60 free, -54 unpack)
- decoded packer: delta histogram -> sorted-list Huffman
  (before-equals leaf insert via `bhi`), roxr MSB-first code
  collect, nibble length table, -17 output-budget bailout via
  saved-SP longjmp
- decoded unpacker: unmasked `win>>bits` reader, 4-byte-node trie
  with word offsets, 1024-entry 10-bit fast table, DBMI leaf
  detect, delta accumulate
- C reconstruction `source/xpkSMPL.c` + AUTOINIT lib.s + two-pass
  genfunctab build (same scheme as xpkSMPL 1.1/xpkLZW5)
- host verification (HOST_TEST):
  - fixed 22-byte packed pnode stride for host
  - fixed workmem endianness model: all trie/table access via
    explicit BE helpers (NRD16/NRD32/NWR16/NWR32) -- native on
    m68k, BE on host; the initial native-access version inverted
    the node hi/lo word convention on little-endian hosts
  - 23/23 round-trips; bad signature -> -26; encoder byte-exact
    vs independent Python model of the disassembly
- m68k build: vectors resolve, descriptor byte-identical modulo
  relocated offsets, GCC codegen faithful
