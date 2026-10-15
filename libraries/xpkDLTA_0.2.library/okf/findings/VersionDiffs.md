---
type: Finding
title: Differences vs xpkDLTA 0.3(000)
---

# 0.2 vs 0.3(000)

Same skeleton and the same delta codec idea; 0.3 is a substantial
rework (see the [0.3 bundle](../../xpkDLTA_0.3_000_.library/okf/findings/VersionDiffs.md)
for the full table).  Highlights from the 0.2 side:

- 0.2 embeds XpkInfo/XpkMode **in the library base** (dataSize 0xfc,
  built by InitStruct); 0.3 moved them to code islands and shrank the
  base to 0x26 — the layout 0.3 shares with xpkNONE 1.5.
- 0.2 carries one byte of state across chunks via `xsp_Sub[0]/[1]`
  and enforces `InLen <= OutBufLen` (-10) / `InLen <= 64K` (-11);
  0.3 dropped all of that — and accidentally dropped the
  `xsp_OutLen` write in unpack.
- 0.2's codec loop is off-by-one (`subq.w/bcc`, InLen+1 bytes);
  0.3 counts correctly (`subq.l/bne`).
- 0.2: xi_Flags 0x2000, MinPkInChunk 1, mode "ByteMode" (flags 0,
  no speeds); 0.3: xi_Flags 0x2009, MinPkInChunk 0, mode "bytemode"
  (flags 1, speeds 531/743), xi_MasterVersion 2 (was 1).
- 0.2 strings: "DLTA"/"DELTA v0.2"; 0.3: "Delta"/"Delta
  Encryptor V0.3" and a proper `$VER:` id string.
