# config.library — defects (superseded, see quirks.md)

The authoritative quirks/defects list is `quirks.md`.  This file keeps
the numbering of the original notes but **corrects two entries that
were oracle-harness artifacts, not library behaviour**:

3. ~~`_setnum`/`_getnum` FreeVec a stack address~~ — **retracted**.
   That observation came from a harness where `expunge`'s
   `exec Remove(lib)` ran with unlinked `ln_Succ/ln_Pred`, scribbling
   on absolute `$0`/`$4`; the subsequent `moveal 4,a6` in `_sprintf`
   then wandered and happened to land on the FreeVec stub.  With the
   lib properly linked in a list there is no stack-address FreeVec.

4. ~~return values are garbage~~ — **partially retracted**.  `SetNum`
   returns `SetStr`'s real 1/0 status; `GetNum` returns the parsed
   long — BUT it ignores `StrToLong`'s success flag, so an
   unparseable value returns the *stale stack cell* (see quirks.md #5;
   oracle `getnum-bad` reproduced the previous call's result, 1234).

Remaining confirmed defects — full detail in `quirks.md`:

- version field says 3.0 while idstring says "config 1.0" (#4)
- hunk table allocates 0x56 longs vs DATA body 0x55 (#2)
- scrambled non-ascending RELOC32 groups (#3)
- `SetStr` whole-file rewrite via MODE_NEWFILE; write results ignored (#6)
- blank line injected before section headers on rewrite (#7)
- unconditional last-byte strip after FGets (#8)
- exact `" = "` separator required for key match (#9)
- section name prefix-match only (#10)
- blank lines dropped on rewrite (#11)
- intuition/graphics bases opened and never used; dead `_null0` and
  reg-save shims (#13)
