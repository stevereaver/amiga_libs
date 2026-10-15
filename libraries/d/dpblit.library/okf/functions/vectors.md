---
type: Functions
title: dpblit.library (DPBlitBase) vector map
---

# Vector map (functab h3+0, 7 absolute longs -> hunk0)

| LVO | target | |
|-----|--------|-|
| -6   | 0x0c4 Open    | opencnt++, clear DELEXP, return lib |
| -12  | 0x0d6 Close   | opencnt--, deferred-expunge at 0    |
| -18  | 0x100 Expunge | set DELEXP; if cnt==0 closelib gfx, Remove, FreeMem |
| -24  | 0x000 reserved| the hunk0+0 `moveq #0; rts` stub    |
| -30  | 0x266 | main blit setup: 168B frame, OwnBlit/WaitBlit, fills chip buffer |
| -36  | 0x73c | single blit pass: programs blitter regs at chipbase+0x40.. |
| -42  | 0x842 | blit loop over planes via helpers 0x158/0x1d4/0x21c  |

Helper subs (not vectors): 0x158/0x1d4/0x21c (wrap gfx -960 with
d1=4/0/8 or direct field read when GfxBase version <39),
0x9b0 (byte fill), 0x9c8 (32x32->64 multiply), 0x956 (open
graphics.library -> lib+0x44), 0x98a (close it).

initfn (h0+0x20): fills ln_Type/ln_Name/lib_Flags/version/rev/
idstring, copies hunk1[0..27] to lib+0x30 (see quirks), opens
graphics.library.  All blit entry points run through
a4=lib+0x30: a4@(20)=GfxBase, a4@(24)=chip base 0xdff000.
