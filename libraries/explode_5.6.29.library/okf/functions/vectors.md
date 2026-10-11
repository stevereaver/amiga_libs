# explode.library vector map

LONG function table at hunk+0x82, 6 entries + -1 terminator.

| LVO | Target | Name | Notes |
|----:|--------|------|-------|
| -6  | open | `LibOpen` | OpenCnt++, clears flag byte +34 bit3, returns base |
| -12 | close | `LibClose` | OpenCnt--; at 0 with flag bit3 set -> shared expunge, else 0 |
| -18 | ret0 stub | (expunge slot) | `moveq #0,d0;rts` — real expunge is **never reachable via the vector** |
| -24 | ret0 stub | reserved | same stub as -18 |
| -30 | `_ExpExplode` | Explode | asm trampoline, see below |
| -36 | `_ExpMark` | mark-for-expunge | `bset #3,base+34` — arms expunge at last close |

## Base layout (datasize 0x32 / 50 bytes)

| Off | Field |
|----:|-------|
| 34 | `eb_Flags` — bit3 = expunge-when-count-hits-0 |
| 36 | `eb_DosBase` |
| 40 | `eb_SegList` |
| 44 | `eb_SavedW` — word at dos slot before patching |
| 46 | `eb_SavedL` — long at dos slot+2 before patching |

## LibInit (AUTOINIT initfunc)

1. `OldOpenLibrary("dos.library",33)` -> base+36; NULL -> deadend
   `Alert(0x80038007)` (AT_DEADEND|AG_OpenLib|AO_DOSLib).
2. `Forbid()`.
3. `slot = dosbase-150`; saves the 6 bytes there (word+long).
4. Three slot forms:
   - `4EF9` (`jmp abs`): copies slot+2 into the stub's jsr operand,
     installs **stub+2** — vector = `jsr realLoadSeg` then our check.
   - `70 xx 60 xx` (`moveq #n,d0;bra.w`): a foreign wedge of the same
     family — copies the moveq immediate into our stub, follows the
     bra to the real function, installs **stub+0** (moveq preserved).
   - anything else: recoverable `Alert(0x00028007)`, installs nothing.
5. `SetFunction(dosbase,-150,stub+delta)`; `CacheClearU()` if
   exec version >= 37; `Permit()`; returns base.

## -30 Explode calling convention

Not a normal vector call. Entered via `jsr` with the caller's
d0-d7/a0-a6 (60 bytes) already pushed beneath the return address and
the **packed control block immediately after the jsr** — the return
address becomes the source pointer (a5). It:

1. `subq.w #1,lib_OpenCnt` — consumes one open per call (!)
2. pops a5 (return address = &control block), builds the a4 frame,
   runs the decoder
3. walks to hunk0 via `_exp_hunkwalk`, returns first-hunk-data-addr in
   the saved-d0 slot
4. `CacheClearU` on exec>=37, `movem.l (sp)+,d0-d7/a0-a6`, `rts`

## Expunge semantics

The real expunge (reached only via Close with flag bit3 set) checks
that the LoadSeg slot is still `4EF9` pointing at stub+0 or stub+2 —
i.e. nobody re-patched after us. Only then: `Remove()`, restores the
saved 6 bytes, `CloseLibrary(dos)`, `FreeMem(base)`. Otherwise returns
0 (refuses to expunge while the wedge can't be undone).
