# Functions

## LibInit (@0x20, init routine via MakeLibrary)

- a5 = d0 base; seglist -> +0x22.
- Writes ln_Type 9, ln_Name (reloc'd), lib_Flags 6,
  lib_Version 0, lib_Revision 3, lib_IdString (reloc'd).
- Far-data fixup: count at hunk1+4, offsets from +8;
  `*(a5+0x30+off) += a5+0x30` per entry.  Count is 0 in
  the shipped table -- no-op.
- Calls OpenLibraries (SysBase -> hunk3, OpenLibrary
  "intuition.library" -> hunk3+4).  Returns 0 on failure
  else the base.
- Epilogue overlap trick: `beq` on success lands on the
  `200d` tail of `cmpiw #0x200d,d0` = `movel a5,d0`;
  the failure path runs the dead cmpiw then returns 0.

## LibOpen (@0xc4) / LibClose (@0xd6) / LibExpunge (@0x100)

Standard deferred-expunge trio (SAS/C `subqw #4,sp`
frame boilerplate included).  Expunge calls
CloseLibraries (CloseLibrary on the intuition stash),
Remove, FreeMem(negsize..negsize+possize).

## OpenLibraries (@0x158) / CloseLibraries (@0x190)

- Open: `*(4)` -> hunk3+0 (SysBase); OpenLibrary
  ("intuition.library", v0) -> hunk3+4; returns 1 on
  failure, 0 on success.
- Close: CloseLibrary on hunk3+4 if set; clears it.

## RARequest (@0x1c8, LVO -30)

```
res = -3
Forbid()
ss = FindSemaphore("ReqAttack SubLibrary")   /* -594 */
if (ss && AttemptSemaphoreShared(ss)) {      /* -720 */
    Permit()                                  /* -138 */
    port = FindPort("ReqAttack Warp Core")    /* -390 */
    if (port) {
        warpcore = *(ULONG*)((UBYTE*)port + 46)
        res = warpcore[-30](d1, a0, a1)
    }
    ReleaseSemaphore(ss)                      /* -570 */
}
Permit()                                      /* -138, 2nd! */
if (res == -3) res = intuition[-588](d1, a0, a1)
return res
```

## RABuildRequest (@0x290, LVO -36)

Identical flow with one extra d0 arg forwarded to both
the WarpCore slot (-36) and the intuition fallback
(-594 BuildEasyRequestArgs).

## Overlapping instructions

The init epilogue uses `cmpiw #0x200d,d0` as a two-in-one
landing pad: enter it mid-operand and `200d` executes as
`movel a5,d0`.  Same idiom in the hunk1 scan loop
(`bccs` re-enters `1cd9` mid-instruction).
