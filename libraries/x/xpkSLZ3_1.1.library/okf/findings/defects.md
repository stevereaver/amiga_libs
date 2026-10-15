# defects / quirks

1. **Seglist store past PosSize.**  LibInit writes the seglist at
   base+38 while InitTable dataSize is 38 -- the store lands in
   allocator padding (AllocMem rounds 38 -> 40).  Works by luck of
   allocation granularity.
2. **xm_PackMemory=1.**  The mode descriptor claims 1 KB of pack
   memory although XpksPackChunk allocates 262,146 bytes itself on
   every call.  If xpk.library used the descriptor to pre-allocate
   workmem the value is simply wrong; kept verbatim.
3. **No outlen writeback on unpack.**  XpksUnpackChunk returns d0=0
   without writing xsp_OutLen; the caller must know the expanded
   size from the chunk header.
4. **Brute-force tail scan.**  After the 16-entry LRU, the packer
   sequentially compares EVERY position back to pos-4095 whenever
   the LRU was fully populated -- O(4095) worst case per byte.
   Deliberate "pack slow, unpack fast" design.
5. **Flag byte 0 fast path.**  A literal-run flag of 0x00 makes the
   decoder copy 8 bytes unconditionally -- the packer relies on
   flag-bit order to keep semantics identical to bit-by-bit decode.
