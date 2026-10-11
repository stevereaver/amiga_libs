# context table (256 KB workmem)

- AllocMem(0x40002, MEMF_PUBLIC) per pack call; 0x10000 LONGs
  cleared to -1 (the extra 2 bytes are padding)
- index: ctx = (src[i]&63)<<6 | (src[i+1]&63)  ->  4096 contexts
- each context = 16 LONGs = LRU list of positions where that byte
  pair last occurred
- insert (hunk 0x13c): shift the 16-long list right one slot,
  write the new position at [0]
- lookup: up to 16 candidates, newest first; the first candidate
  below pos-4095 ends the LRU phase (list is newest->oldest);
  exhausted list -> sequential backward scan to pos-4095
