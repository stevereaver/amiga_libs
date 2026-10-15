# Structures

- [XpkSubBase](XpkSubBase.md) — 0xfc-byte base: Library + seglist +
  embedded descriptors
- [XpkInfo](XpkInfo.md) — packer descriptor, embedded at base+0x26
- [XpkMode](XpkMode.md) — mode descriptor, embedded at base+0x7e ("ByteMode")
- [InitTable](InitTable.md) — AUTOINIT table, large InitStruct data,
  word-offset functab
- XpkSubParams: public XPK chunk I/O block (xpk_Develop `xpksub.h`);
  this version reads InBuf/InLen/OutBuf/OutBufLen, writes OutLen and
  uses `xsp_Sub[0]`/`xsp_Sub[1]` (+0x34/+0x38) as the chunk carry.
