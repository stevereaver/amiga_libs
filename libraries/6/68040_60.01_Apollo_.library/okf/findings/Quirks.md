---
type: Finding
title: Quirks and open questions
---

# Quirks — Apollo 68040.library 60.01

- **"68o4o.library"** (with letter 'o', twice) is opened when
  AFF_FPU40 is set. This is the Apollo team's own 68040 support
  library name, deliberately spelled differently so it can coexist
  with a stock "68040.library" (i.e. this stub).
- **AttnFlags == 0x80ff → init *succeeds* without loading.** The
  compare is a full-word `cmpi.w #$80ff,AttnFlags` executed after
  `move.l d7,d0` (d0 = base), so the `beq` exits with success and
  skips OpenLibrary entirely. 0x80ff = all eight low flag bits plus
  bit 15 (AFB_PRIVATE): the Apollo support libraries write this
  value into AttnFlags as their "already installed" marker, so a
  second 68040.library load is idempotent. (An earlier revision of
  this bundle claimed init *fails* here — corrected after
  cycle-level verification in work/oracle.py.)
- **68060 without 040 flag?** Init requires AFB_68040 *first*, so on
  systems where a 68060 does not report the 040 bit the stub fails;
  the FPU40 bit then selects between the 040 and 060 support lib.
- **Leaked OpenLibrary:** the opened library is stored nowhere and
  never closed — by design, it stays resident for the rest of the
  session. Since the stub cannot forward (no fields), callers still
  get the stub itself; only the *name lookup* side effect matters.
- **No user LVOs.** Any code calling a 680x0.library-style API
  function on this base jumps into uninitialized vector space.
- Expunge and ExtFunc share one `moveq #0,d0/rts` (table entries
  identical). LibClose decrements but never expunges.
- lib_Revision is 0 despite the "60.01" version string (InitStruct
  writes `9016 0000`); RT_VERSION is 60.
- Rebuild: `make` in source/ now assembles 68040.s into a
  **byte-identical** image (md5 a87e68a0e398d03466cc5443f524fbe7);
  the earlier gcc codegen build is kept as `make cmodel`
  (68040-c.library, semantic reference only).
