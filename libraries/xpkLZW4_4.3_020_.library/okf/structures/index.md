# structures

- [descriptor](descriptor.md) -- XpkInfo + four XpkMode records
- [workmem](workmem.md) -- the 512 KB+4 packer workspace layout
- XpkSubParams -- shared Froehling XPK parameter block
  (xsp_InBuf 0x00, xsp_InLen 0x04, xsp_OutBuf 0x08,
  xsp_OutBufLen 0x0c, xsp_OutLen 0x10, xsp_Flags 0x14,
  xsp_Number 0x18, xsp_Mode 0x1c, xsp_Password 0x20,
  xsp_LibVersion 0x24, xsp_Tags 0x28, xsp_Sub[4] 0x34)
- XpkSubBase -- `struct Library` + seglist BPTR at +0x22
