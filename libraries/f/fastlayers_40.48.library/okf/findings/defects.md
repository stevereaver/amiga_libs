# fastlayers.library — defects & inconsistencies

## Permanent patching / no unload path

`LibExpunge` is `moveq #0,d0; rts` — the library can never be
expunged, so the SetFunction patches on layers.library live
until reboot.  Consistent with the era's accelerator patches,
but means a failed or stale install cannot be backed out.

## Dead private DELEXP flag

`LibOpen` clears bit3 of the private byte at base+34 and
`LibClose` calls the expunge stub only when that bit is set —
nothing in the binary ever sets it (exec's real `LIBF_DELEXP`
lives in `lib_Flags` @14 and exec sets it, not this byte).
The mechanism mirrors the standard delayed-expunge convention
in the wrong field; even if it were set, the expunge stub does
nothing.  Dead code.

## functab walk off-by-one

The module-relocation loop reads layers' function-table word
offsets starting at **index 1** (`lea ftab+2`) while iterating
vectors from -6.  If layers' functab[0] is the Open entry (the
normal layout), every comparison is shifted by one slot and the
loop re-points nothing; it only works if the target layers
build has a leading non-vector word.  Reproduced verbatim —
see `okf/log.md`.

## jmp->jsr tail-call rewrite

`jmp pc@(d16)` tail-calls to the SwapBitsRastPortClipRect
routine inside the copied module are replaced with
`jsr a6@(-126)`.  A `jmp` does not return, a `jsr` does — if
any patched site was a true tail call, execution continues into
whatever bytes followed it when the vector returns.  The
authors presumably verified the sites are safe for layers 40.x;
the transform is reproduced byte-for-byte.

## Dead DoHookClipRects block

After creating a layer, the code tests `a3 != 1` and calls
`DoHookClipRects(a3, l->rp, a2)` — but a3 was set to 1 by the
code itself (the sentinel hook) and layers preserves a2-a6, so
the block is unreachable.  Reproduced (compiler eliminates it).

## BackFill = (Hook*)1 sentinel

The new layer's `BackFill` pointer is written with the literal
address 1 — a sentinel meaning "no backfill hook" understood
by layers internals.  Any code dereferencing it as a real Hook
would crash; relies on layers checking for the sentinel first.

## LibInit failure leaks

On any failure (OpenLibrary, FindResident, AllocVec) LibInit
returns 0 leaving already-opened libraries and any allocated
block un-freed.  Minor (init-failure path only).

## CreateUpfrontLayer wrapper hook

The -36 wrapper calls the new -186 with `a3=0` (hook NULL) and
forwards the caller's a2 as bm2 — the register juggling in the
original (`exg` chains) nets to exactly this.
