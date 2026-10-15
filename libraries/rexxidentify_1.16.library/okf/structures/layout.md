---
type: Structures
title: rexxidentify 1.16 layout
---

# Layout

- datasize 0x2c -> 34B Library node + 10B private:
  +0x22 flags/pad, +0x24 SysBase, +0x28 seglist.
- In-hunk variable area at h0+0xd92..0xda3 (beyond the 0xd94 body,
  inside the 0xda4 allocation):
  +0xd92 identify.library base, +0xd96 expansion.library base,
  +0xd9a rexxsyslib.library base, +0xd9e commodities.library
  base, +0xda2 u16 ConfigDev count.
- rt_EndSkip = 0xda4 = hunk0 *alloc* size, i.e. resident range
  covers the variable tail too.
- BSS hunk (0x200): +0x00..  ConfigDev pointer array filled by
  FindConfigDev loop at init (count -> h0+0xda2);
  +0x80..0x1ff   32 x 12-byte records used by the ID_LOCKCX/
  ID_COUNTCX/ID_GETCX/ID_UNLOCKCX handlers (record+0 = link,
  +0xe/0x26/0x4e = NAME/TITLE/DESC string slots, +0x82 flags word
  tested with bits 4/2 for ACTIVE).
- RexxMsg input (vector -30): rm_Action@+0x1c, rm_Args[0..]@+0x28;
  handlers consume args at +0x2c/+0x30/+0x34, flag byte +0x11,
  word +0x14.
