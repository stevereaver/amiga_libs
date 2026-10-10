# Log

## 2026-10-11 -- reconstruction complete

- Parsed single-hunk xpkLZW2 2.3 by Niels Froehling:
  RomTag AUTOINIT v1, InitTable@0x64 (dataSize 0x26),
  word-offset functab@0x94 (offsets relative to the marker),
  datatab ver 2/rev 3, static descriptor@0x3aa.
- Decoded the codec: greedy LZ77 (NOT LZW despite the id)
  with a 16K-entry hash (4-byte window w(p)^w(p+2)) + a
  64K-entry pos&0xffff chain ring in a 327,684-byte workmem;
  32-item big-endian flag groups (all-zero = 32-literal
  fast path), match tokens [-dist:u16][len-4:u8], 0x0000
  terminator.
- Key register trick: the best pair is carried packed as
  [dist:len] (swap d2), emit = swap+negw -> -dist; decoder
  seeds the token register with moveq #-1 so reloads
  sign-extend -> a1 + (tok-0x10000) = backward copy.
- Lazy insertion decoded: after a match of length L the
  encoder hashes only positions +1..+3 and +L (the new
  cursor); positions inside the match body are skipped.
  This is the "slow packing" comment notwithstanding --
  it is the FAST seeding scheme.
- Found: PackReset underflow wipes the AllocMem size word
  (5,040 bytes below the block!) -> PackFree's
  FreeMem(ptr,0) leaks the whole 320KB; uninitialised chain
  ring; encoder bound = out+inlen (OutBufLen ignored);
  decoder has NO bound checks and never writes OutLen;
  "cremation" turns out to be the real xm_Description.
- Reconstructed in C (+ two-pass word-offset functab);
  16,229 host round-trips pass, 3,771 expansion rejects
  (-17) -- zero failures under ASan/UBSan.
