# Deferred-expunge flag written to SysBase

`LibExpunge` (code+0xc0) reuses `a6` for two roles:

```
2a4e          moveal a6,a5          ; a5 = lib base
2c78 0004     moveal 0x4,a6         ; a6 = SysBase  <-- a6 clobbered
4a6d 0020     tstw   a5@(0x20)      ; lib_OpenCnt
670a          beqs   real_expunge
08ee 0003 000e  bset #3,a6@(0xe)    ; LIBF_DELEXP on a6 = SysBase!
```

The `bset` intends to set `lib_Flags.LIBF_DELEXP` on the library
base but executes *after* `a6` has been reloaded with SysBase, so
the bit lands on `execbase+0xe` (SysBase flags area) instead.

Consequences:

- The library's own `lib_Flags` is never marked for expunge.
- `LibClose` (which *does* test `btst #3,a6@(0xe)` with `a6` = lib
  base) can therefore never see DELEXP set — deferred expunge
  through Close is dead code.  Once opened, the library can only
  be removed by a direct Expunge call at OpenCnt==0.
- Every deferred-expunge attempt corrupts execbase+0xe bit 3
  (SysBase internals).

Verified under machine68k: Expunge at OpenCnt=1 returns 0, sets
`SYSB+0xe` bit 3, leaves `lib+0xe` untouched; Close to OpenCnt=0
then performs no Remove/FreeMem.  A direct Expunge at OpenCnt=0
works correctly (Remove + FreeMem, returns the seglist read back
through a PC-relative reference to the code-slot at hunk+0x7a).

Same defect class as xpkNONE 1.2 (`a5`/`a6` register mixup on the
deferred-expunge flag), different polarity: NONE 1.2 *tested* the
wrong base on close, RLEN 1.3 *writes* to the wrong base on expunge.
