# Log

## 2026-10-10T16:40:00Z -- reconstruction complete

- Parsed single-hunk xpkLZW3 3.3 (020) by Niels Froehling:
  RomTag AUTOINIT v1, InitTable@0x64 (dataSize 0x26),
  word-offset functab@0x94, static descriptor@0x36c.
- Decoded the codec: greedy LZ77 (NOT LZW despite the id)
  with a 64K-entry hash (4-byte window w^w>>16) + 64K-entry
  pos&0xffff chain ring in a 524,292-byte workmem; 32-item
  big-endian flag groups (all-zero = 32-literal fast path),
  match tokens [-dist:u16][len-4:u8], 0x0000 terminator.
- Key register trick: the best pair is carried packed as
  [dist:len] (swap d2), emit = swap+negw -> -dist; decoder
  seeds the token register with moveq #-1 so reloads
  sign-extend -> a1 + (tok-0x10000) = backward copy.
- Found: PackReset underflow wipes the AllocMem size word
  -> PackFree's FreeMem(ptr,0) leaks the whole 512KB;
  uninitialised chain ring; hard 020+ requirement (unaligned
  movel/movew); post-write bound check; dead "cremation"
  string.
- Reconstructed in C (+ two-pass word-offset functab);
  407 host round-trips pass, 199 expansion rejects.
