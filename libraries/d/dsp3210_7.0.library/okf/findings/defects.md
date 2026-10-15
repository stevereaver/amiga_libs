---
type: Findings
title: dsp3210 7.0 quirks
---

# Findings / quirks

- Same skeleton as the 6.0 sibling: single CODE hunk, COLDSTART
  resident at +0x04, word-offset functab (`ffff` marker … `ffff`),
  only 5 RELOC32 entries — all inside the resident struct
  (matchtag/endskip/name/id/init). Every other internal reference
  is pc-relative.
- Version bookkeeping consistent: resident rt_Version=7,
  initfn writes lib_Version=7 (`movew #7` at h0+0xe0), idstr
  `7.0 (29.8.2021)` postdates 6.0's `(20.8.2021)` by 9 days.
- **New container cookie `0x00fc2011`.** Second magic alongside
  the block cookie `0x32102011`. A longword `0x00fc2011` at +0
  marks an object with a pointer-array table at +4 and an
  embedded MinList at +8. Node layout: ln_Succ/ln_Pred at +0/+4,
  key at +8, payload table at +12. This is the whole point of
  the 7.0 release — every list/table vector now understands it.
- **-60** (h0+0xc62, +0x50 bytes): on a container, scans the
  obj+4 table first, then walks the MinList scanning each
  node's +12 table; non-containers get 6.0's array walk.
- **-66** (h0+0xb98): on a container, exec-Removes and frees
  every node whose node@(8) equals a1; non-containers fall
  through to the factored-out block free at h0+0xbe0 (6.0's
  -66 body verbatim, still -1/0 status).
- **-90** (h0+0xc10, +0x30 bytes): on a container, drains the
  embedded list with exec RemHead(-258) freeing each node;
  non-containers keep the 6.0 NULL-terminated pointer-array
  free via the 0xbe0 subroutine.
- **-54** (h0+0xb50, +8 bytes): explicit status protocol like
  6.0's -66 — pushes a6 as the result slot, so bad args now
  return the **lib base** (nonzero!) instead of the adjusted
  block pointer; FreeMem path returns deterministic 0; the
  a1-dispatch path returns the secondary base's -60 result.
  Alignment check relaxed from `andib #3` (long) to `btst #0`
  (even), matching 6.0's -66 relaxation. Oracle: -54 ->
  0x100000 (6.0: 0x4ff00).
- **Loader alloc tail** (h0+0x10e6): when the destination
  object is a container, the AllocMem size grows by 12 (node
  header), the embedded list is NewList-initialised if empty,
  and the new block (block+8 as node) is exec-AddTail(-246)ed
  with the array pointer stored at node+8; otherwise the old
  NULL-array append at a4 is used.
- **DSPRelocate** (h0+0x3f8): the inlined NULL-array name scan
  was replaced by a `bsrw` to the -60 body (h0+0xc62), so
  relocation now resolves through the container-aware lookup.
  Net -0x10 bytes in front of -48/-78, which moved 0x98e/0x99a
  -> 0x97e/0x98a.
- Cosmetic: in the -48/-78 shared tail the `movel #0x800,d1`
  now sits inside the `cmpiw #36,a6@(20)` guard (exec -642 =
  AvailMem-flavoured call only attempted on v36+), instead of
  being loaded unconditionally.
- **Error codes unchanged** — the odd-negative set
  (-1/-3/-5/-7/-11/-21/-23/-31) is byte-for-byte identical,
  moved -0x10 with the shared body.
- DSP register-name table moved 0xf32 -> 0xfea, still ends
  with a `0000` terminator and no pad.
- Hunk body now ends exactly on the final `rts` (h0+0x11de) —
  6.0's 2 tail pad bytes are gone. Net body growth vs 6.0:
  +252B = -0x10 (DSPRelocate inline->call) +8 (-54) +~0x46
  (-66 entry+sub split) +0x30 (-90) +0x50 (-60) +~0x30 (alloc
  tail) -2 (pad), rest displacement-only shifts.
- `cmpiw #36,a6@(20)` v36-guard and the `tstb a6@(43)`
  DSPCOMPAT probe logic are unchanged.
