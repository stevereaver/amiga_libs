---
type: Structures
title: tablet 37.7 layout
---

# Layout

- datasize 0x1a2 -> 34B Library node + 0x180 private.
  +0x22 seglist (set by initfn; returned by Expunge).
  +0x2e..+0xf1  verbatim copy of hunk1 bytes 0..0xc3 (made by
    initfn's own copy loop, then one self-fixup adds the priv
    base to the long at priv+0x8e).
- hunk1 (DATA, also the InitTable hunk):
  +0x00 unused zero long (rt_Init points at +0x04)
  +0x04 InitTable: dsz 0x1a2, functab ->h0+0xca4, dtab 0,
       initfn ->h0+0x20
  +0x14 'utility.library'      +0x24 '$VER: tablet.library 37.7
       (28.04.93)'             +0x49 '(c)1992, TriMedia, Inc.'
  +0x62/+0x6c/+0x76 'APCommand' x3 (undeduplicated const copies;
       the three are used as the FindPort names in vectors
       -30/-36/-48 resp.)
  +0x82 'TabletPatch'          +0x8e self-ptr (fixed to &priv+82)
  +0x92 'intuition.library'    +0xa4 'input.device'
  +0xb2 'intuition.library'    (second copy -> Interrupt ln_Name)
  +0xc4 fixup count (1)        +0xc8 fixup offset (0x8e)
- Private/runtime fields (priv = lib+0x2e):
  +0x80 u16 'patch installed' flag (installer writes 1)
  +0xc4 utility.library base; +0xc8 lib back-ptr
  +0xcc SignalSemaphore #1 (~46B)   +0xfa SignalSemaphore #2
  +0x128 client list head (NewList'd; nodes are the 68B alloc
         blocks from vector -30; node+8 = public handle)
  +0x134 free pool list head (NewList'd; 120 x 64B nodes carved
         from the +0x158 AllocMem(0x1e00) block; samples are
         node+8/+12 match keys, node+16..+31 payload)
  +0x140 20B live sample buffer (vector -42's >=39 CopyMem src
         via handle+52)
  +0x148/+0x14c handler trampolines h0+0x18c/h0+0x2f0 (per alloc)
  +0x150 priv base ptr; +0x154 dword flag (node+60&1 mirror)
  +0x158 pool AllocMem result; +0x15c intuition.library base
  +0x160 anon MsgPort #2; +0x164 0x30B input.device ioreq
  +0x168 22B Interrupt node (pri 50, name 'intuition.library',
         is_Data=IntuitionBase, is_Code=h0+0xc54/0xc8c)
  +0x16c intuition patch target (+0x704 v39 / +0x76e v37)
  +0x170 'TabletPatch' public MsgPort
- Handle (vector -30 result = 68B block +8):
  +8 link-next key, +20 -> 80B cloned TagItem list, +36/+40 match
  keys, +44 ln_Type=5 msg byte, +52 -> priv+0x140 live data,
  +56 replyport ptr, +60 flag word.
- DoIO ioreq (0x30B): io_Command@+28 = 10 then 9; payload@+40 is
  the patch-target then the Interrupt node (order swapped on
  uninstall) — device-private 'TabletPatch' protocol, not the
  std IND_ io_Data slot.
