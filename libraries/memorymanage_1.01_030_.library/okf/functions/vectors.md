# memorymanage.library — vector detail

## Lifecycle (-6/-12/-18/-24)

Standard Amiga library semantics:

- **Open** — `opencnt++`, clears delayed-expunge bit (flag3), returns
  base in d0.
- **Close** — `opencnt--`; if nonzero returns 0. If zero and flag3
  set, tail-branches into expunge.
- **Expunge** — sets flag3; if opencnt nonzero returns 0. Otherwise
  unlinks the node, `FreeMem(base-negsize, negsize+possize)`, returns
  seglist.
- **Reserved** — return 0.

## -30 `mm_enable` (hunk+0x3fe)

First-user enable path:

1. If `base->rootinfo` nonzero → return it (already enabled).
2. `Supervisor(_mm_sup_save)` — PMOVEs current CRP/SRP/TC into
   `base->saved` (24 bytes).
3. Tests saved TC status bytes (saved+18 & 0x80 = CRP valid;
   saved+22 & 0x80 = SRP valid; saved+26 & 0x80 = TC enable bit):
   if the PMMU was already translating, takes the foreign path —
   sets `base->foreign=0xff`, freelist=0, and extracts the live root
   pointer from the saved CRP (saved+4..7 & ~15) into rootinfo.
4. Otherwise AllocMem(0x220, MEMF_PUBLIC) → aligns to 16, fills 128
   root entries `i*32MB+1` (DT=1, i.e. type-1 descriptor), links the
   block into a node record at +512
   (`node = {next, block, descaddr, olddesc}`), sets freelist and
   rootinfo.
5. Patches `_mm_ctx_enable` block bytes 4..7 and 12..15 with the root
   pointer (both CRP and SRP get it) and `Supervisor(_mm_sup_load)`.

## -36 `mm_disable` (hunk+0x554)

`--usecount != 0` → return immediately. Otherwise, if `foreign` was
clear, `Supervisor(_mm_sup_load)` on `_mm_ctx_disable` (restores the
saved CRP/SRP/TC captured at enable time). Then walks the node
freelist: for each node, if `descaddr` nonnull, writes `olddesc`
back through it (restores the descriptor the table entry replaced);
then FreeVec every node block. Clears freelist and rootinfo.

## -42 `mm_map` (a0=virt, a1=phys, d1=flags) — lib.s

Reconstructed in assembly verbatim — see `algorithms/pagetables.md`.

## -48 `mm_mapid` (a0=virt) — lib.s

`movem.l d1/a1,-(sp); movea.l a0,a1; clr.l d1; bsr mm_map;
movem.l (sp)+,d1/a1; rts` — identity-map one page.

## -54 `mm_saveregs` (a0=buf) / -60 `mm_loadregs` (a0=buf)

C wrappers calling `Supervisor(_mm_sup_save/_mm_sup_load)`. Buffer
layout: +0 CRP (8B), +8 SRP (8B), +16 TC (4B). `_mm_sup_load` also
runs `pflusha` then `rte`.

## -66 `mm_vatophys` (a0=virt)

If rootinfo null → returns 0. Otherwise `Supervisor(_mm_sup_ptest)`
→ `ptestr #1,a0@,7,a1` writes the level-7 descriptor into `a1`.
Returns `(desc & ~0xfff) | (va & 0xfff)`.
