# xpkFAST.library 1.10 — OKF index

XPK compression sublibrary: **"FAST alias WOOP or LZRW++"**
by Christian von Roques — an LZ77-family codec with a 4 KB
window, max match length 18, literals written forward and
control/match words written *backward* into the same output
buffer.  Two packers share one stream format: a greedy
single-candidate "speedy" packer (mode **<= 80**) and a
hash-chain "crawling" packer (mode > 80).  AUTOINIT library,
LONG absolute functab.

This is the successor of `xpkfast_1.06.library` (AMIGALIBS-101)
and `xpkFAST_1.2_000_.library` (AMIGALIBS-80).  The two packers
and the decoder are **instruction-for-instruction identical** to
1.06 (modulo assembler-encoding aliases: `aslw #2` vs
`addw d0,d0` twice, `cmpb` vs `cmpib`, `andib` vs `andb`) —
the differences are confined to lifecycle, dispatch, and
metadata:

- `dataSize = 0x22`: the library is a **bare `struct Library`**
  (34 bytes, no private fields).  Exec calls reload a6 via
  `moveal 4:w,a6`; the seglist lives in a code-hunk cell at
  code+0x7a (written through a relocated absolute.LONG store).
- Mode boundary moved: `mode <= 80` -> speedy (1.06: `< 80`).
- AllocMem flags byte = 1 (MEMF_PUBLIC bit); 1.06 passed 0.
- PackChunk releases a mismatched workmem by `jsr a6@(-42)` —
  through its own PackFree vector; 1.06 inlined the body.
- UnpackChunk wrapper no longer preserves a1 (decoder clobbers
  it anyway — scratch register, harmless).
- ln_Type InitStruct quirk fixed: written at +8 (1.06 wrote +12,
  inside ln_Name, then overwrote it).
- idstr `xpkFAST 1.10 (20.09.1998)\r\n` — the `$VER:` cookie is
  gone; descriptor longname lost the version suffix
  ("FAST alias WOOP or LZRW++").
- RomTag `rt_MatchTag` longword is **not** in the hunk reloc
  list — it stays the literal file offset 4 at runtime (same as
  1.06; 1.2 relocates it).  Reloc offset 0x0 still corrupts the
  dead `moveq #-1,d0` entry stub at load.

- Binary: `binary/xpkFAST_1.10.library` — 2136 bytes, m68k,
  one hunk (typed HUNK_DATA) of 1964 bytes + reloc table.
- Reconstruction: `source/` — C core (`xpkfast.c`) + AutoInit
  glue (`xpkfast_lib.s`), byte-verified against the original
  under a Musashi 68000 oracle (37 randomized cases: packed
  streams, round-trips, workmem sizes, alloc/free log — 0 diffs).
- Library name `xpkFAST.library`, XPK id `'FAST'`,
  flags `0x8009`, two modes "speedy" (upto 79) / "crawling"
  (upto 100; default 50 -> speedy).

## Contents

- `functions/vectors.md` — LVO table + entry points
- `algorithms/format.md` — stream layout and dispatch (identical
  to 1.06's wire format; see its bundle for the deep detail)
- `structures/layout.md` — XpkSubParams, workmem maps, lib base,
  datatab, descriptor, the code-hunk seglist slot
- `findings/defects.md` — shipped quirks and bugs (1.06's plus
  the 1.10-specific ones)
- `log.md` — RE session log
