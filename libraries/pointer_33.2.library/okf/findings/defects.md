# pointer 33.2 — defects & inconsistencies

1. **Uninitialized `iff` local on early-exit paths**: in the original
   loader, if DOS opens but iffparse fails to open (or the spec
   AllocMem fails), the cleanup reads a stack slot that was never
   written — the "iff" pointer is only stored after `AllocIFF`
   returns.  The garbage is usually benign (it is compared against 0),
   but a nonzero stack value would run `CloseIFF`/`FreeIFF` on a
   non-IFF pointer.  Preserved faithfully in the reconstruction (the
   compiler emits the same `may be used uninitialized` warning).

2. **Spec writes through NULL on malformed ILBM**: in the BODY scan
   loop, `spec` is set to 0 on a non-FORM/ILBM container and on a
   missing BMHD, yet the `while(ParseIFF==0)` scan continues and can
   write `spec[2]`, `spec[1]` etc. through NULL on a subsequent BODY
   chunk.  Only reachable with a multi-FORM corrupt file; preserved.

3. **-24 (RESERVED) lands on the ID-string tail**: the reserved
   functab entry's offset is 0x24, pointing at `\r\n\0\0` — executing
   it would run garbage.  Harmless because the reserved slot is never
   dispatched.

4. **Embedded spec bodysize = 0**: the fallback spec's size field is
   genuinely 0 in the original data hunk.  `PtrFreeSpec` is never
   called on it (cleanup checks `cur != &pd->spec`), so the zero is
   harmless — but a client that copied the spec and freed it blindly
   would `FreeMem(img, 0)`.

5. **GRAB coordinates are negated**: spec[3]/spec[4] get `-grab[0]` /
   `-grab[1]`.  This is intentional (the stored hotspot is a signed
   offset into the image), verified against the disassembly.

6. **Fixup table is overwritten at runtime**: pd+0x50/pd+0x54 hold the
   init-time fixup list and are later clobbered by the dos/iffparse
   base pointers — fine because fixups are only consumed once, but it
   makes the runtime block hard to inspect statically.
