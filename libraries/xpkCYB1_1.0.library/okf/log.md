# Work log

- Reused work/*.asm disassembly
- C reconstruction (prior agent), verified `make clean && make`
- XPK LVOs resolved against xpk_Develop xpksub_lib.i / xpksub.h
- OKF bundle written

## 2026-10-15 — byte-identical asm reconstruction

- Prior okf claimed "Non-AUTOINIT XPK sublib" — wrong: rt_Flags is
  0x80 (RTF_AUTOINIT) and hunk+0x78 holds a real InitTable
  (dataSize 0x4a, functab +0x88, datatab +0xb4, initfn +0xd4).
  The "absolute-longword function table" part was right.
- Added `source/xpkCYB1_h0.s`: verbatim GNU-as of the whole hunk —
  entry stub, RomTag, name/version strings (IdString label sits mid-
  string at +0x33 to keep the `$VER:` skip), InitTable, 10-entry
  absolute-long functab (-1 terminator), InitStruct datatab, six code
  paths, static XpkInfo/XpkMode island.
- gas folds `movel #-1,d0` to `moveq` — raw-emitted
  `.short 0x203c,0xffff,0xffff` for the shared -1 stub.
- RELOC32 tail is ascending; GNU ld emits the same order — no fixup.
  Result: md5 `51c68810ef67538e734e291c15493bd8`, byte-identical.
- `work/oracle.py` (machine68k): absolute-long functab decode, exec
  Remove/FreeMem stubs; drives init (sysbase+seglist into lib base),
  Open x2, reserved -24, XpkInfo dump (static island at hunk+0x164,
  XpkMode at hunk+0x224), all five packer slots -> -1, deferred + real
  expunge.  orig.log == rebuild.log — RUNTIME-IDENTICAL.
- Confirmed quirks: ln_Type byte-write goes to +0x0c and is clobbered
  by the ln_Name long at +0x0a (built node keeps ln_Type=0);
  expunge reads SysBase from lib+0x22.
