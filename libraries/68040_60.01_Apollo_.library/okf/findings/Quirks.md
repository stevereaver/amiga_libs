---
type: Finding
title: Quirks and open questions
---

# Quirks — Apollo 68040.library 60.01

- **"68o4o.library"** (with letter 'o', twice) is opened when
  AFF_FPU40 is set. This is the Apollo team's own 68040 support
  library name, deliberately spelled differently so it can coexist
  with a stock "68040.library" (i.e. this stub).
- **AttnFlags == 0x80ff → init fails.** The compare is a full-word
  `cmpi.w #$80ff,AttnFlags`: all eight low flag bits plus bit 15
  (AFB_PRIVATE). Likely an anti-emulation/ill-defined-config gate —
  exact intent unknown (open question).
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
- Rebuild differences: reconstructed code is semantically identical;
  byte offsets differ (gcc codegen); same single-hunk layout and
  absolute-long function table.
