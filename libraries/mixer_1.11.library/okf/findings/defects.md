---
file: defects
---
# Findings

- **Expunge is disabled.**  Vector -18 in both functabs points at a
  `moveq #0,d0;rts` stub @0x3de.  The real expunge routine @0x3e2
  (Remove+FreeMem the base, CloseLibrary pci, codec shutdown) is
  unreachable dead code; called directly with OpenCnt==0 it performs
  a correct expunge and returns the seglist.
- **Close's DELEXP handling is vestigial.**  On last close it tests
  LIBF_DELEXP (bit 3 of lib_Flags) and branches — but both branches
  (`0x3da`/`0x3de`) return 0, so the flag is never acted on.
- **OpenCnt lives at +32, not +30.**  The library counts opens in
  the tail padding word past the standard `lib_OpenCnt`; the real
  field stays 0 forever (harmless internally, nonstandard).
- **-42 dispatcher stack bug.**  Jump-table entries 10/11 (channels
  11,12) point at 0x6f6 which `bra`s to the dispatcher's shared
  movem-pop+ret-1 exit — without unstacking the jsr return address.
  The frame is misaligned and execution goes wild (oracle logs
  writes near address 0; it eventually returns -1 by accident).
- **Tamper/integrity check.**  Init sums the decryptor + payload
  region (@0xd0..0xf5f); any nonzero sum skips stage 2 and init
  returns 0.  The two words @0xd0-0xd3 (`3348 5e79`, inside the
  summed region but never executed) are the fixup that zeroes the sum.
- **Hardware dongle.**  Before scanning for codecs, init polls
  either `word[[pcilib+38]+2]&0x3000==0x2000` (pci v2 path) or
  `byte[[pcilib+38]]&8` (pci v5 path); failure opens an intuition
  EasyRequest "Hardware ID code missing..." — ELBOX copy protection.
  The message is XOR-obfuscated in the binary (key 0xaaaaaaaa).
- **Rolling XOR.**  Payload cipher feeds already-decrypted plaintext
  back as keystream (0x90B lag), so tampering with one long corrupts
  everything downstream — in addition to the checksum.
- **rt_IdString points mid-string** (+0x32 = "mixer.library 1.11...",
  i.e. past the "$VER: " prefix; the ver string is longer).
- **Unreferenced `moveq #-1,d0;rts`** @h0+0 before the RomTag.
- **32B unscrambled tail** @0xf60 lies outside both the decrypt and
  the checksum regions (possible serial/padding).
- Init reads its **incoming a0 straight off the caller stack frame**
  (`sp@(16)` under its own movem) to recover the seglist — assumes a
  fixed movem layout; works because it is the first thing it saves.
