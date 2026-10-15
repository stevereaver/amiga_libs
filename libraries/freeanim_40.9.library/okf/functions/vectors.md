# freeanim.library 40.9 — vector map

Word-offset functab @ h0+0x64 (`ffff` markers): entries are
16-bit offsets **from the functab address**.

| LVO  | entry | target | function |
|------|-------|--------|----------|
| -6   | 0x8c  | 0xf0   | Open: `addq #1,lib+0x20; move.l a6,d0; rts` |
| -12  | 0x94  | 0xf8   | Close: dec opencnt (guarded vs underflow); if 0 && LIBF_DELEXP -> bsr Expunge, return seglist |
| -18  | 0x30  | 0x94   | Expunge: if opencnt!=0 -> set LIBF_DELEXP(3) at lib+0xe; else exec.Remove(lib), FreeMem(lib-negsize, neg+pos) |
| -24  | 0x2c  | 0x90   | reserved: `moveq #0,d0; rts` |

initfn @0x120: `subq #4,a7; move.l a0,d1; movea.l d0,a0;
move.l a6,(a7); move.l d1,0x22(a0); addq #4,a7; rts`
— stores seglist at lib+0x22; the `a6` store into the stack slot
is dead. Returns d0=lib.

Dead code at h0+0: `moveq #-1,d0; rts` — unreferenced stub,
likely a link-time DOS-guard (a `.library` file's first word is
the hunk magic normally; here the body begins with it).

No calls outside exec (Remove -0xfc, FreeMem -0xd2).
