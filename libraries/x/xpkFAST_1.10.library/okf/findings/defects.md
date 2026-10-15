# xpkFAST 1.10 — shipped quirks and defects

All of 1.06's codec defects are carried over unchanged (the
packer/decoder bodies are identical), plus lifecycle quirks.

## Carried over from 1.06 (see its findings doc for detail)

1. **Unrelocated `rt_MatchTag`** — stays file-offset 4 in the
   loaded image; harmless only because exec never reads it.
2. **Reloc at offset 0** corrupts the dead entry-stub
   immediate.  Dead code.
3. **Reset vectors are NO-OPs** (-24/-48/-60 stubs);
   XpksPackReset/UnpackReset do nothing — tables are refilled
   every pack anyway.
4. **Decoder reads/writes past its streams**: trailing
   literals + pad-flag bits decode trailing garbage past
   InLen; callers must not rely on exact unpacked length.
5. **Crawler emits out-of-bounds literals**: its head loop only
   checks `a0 >= in+2` at flag-word completion, so up to ~15
   bytes past the input are packed as literals; the decoder
   dutifully expands them (they land past InLen).
6. **Crawler's tail drain injects a garbage flag bit** from d0's
   stale bit31 (always 1 after the last match path).
7. **Stream collision** is the only error path: if backward
   words reach the literal frontier the packer returns 0 and
   the wrapper maps that to -17 (XPKERR_StreamError-ish).
8. **Speedy hash is stateful** — d1's middle byte is never
   cleared, so the effective index is
   `((prev_index>>?) | gram)`.  Only the low 16 bits matter.
9. **`xsp_OutBufLen` is ignored** — pack may overflow the
   caller's buffer.
10. **Unpacked length is never verified** — the decoder stops
    on stream cursors, not on output length.

## 1.10-specific

11. **Seglist lives in the code hunk** at code+0x7a — a mutable
    global shared by all open instances (fine for a single
    seglist, but it's process-global state written via an
    absolute store on hunk relocation).
12. **`jsr a6@(-42)` for the mode-switch free** — PackFree is
    invoked through the lib's own negative-size vector slot, so
    a SetFunction(-42) patch would intercept internal calls.
    Cosmetic.
13. **ln_Type InitStruct fixed** (+8 not +12) — 1.10 actually
    repairs 1.06's bug.
14. **Mode boundary drifted across releases** — speedy is
    `mode < 80` in 1.06, `mode <= 80` in 1.10, and `mode < 79`
    in 1.2.  The 1.10 descriptor still advertises speedy "upto
    79", so mode 80 takes the SMALL (0x10000) hash table while
    the descriptor claims it should be crawling — an off-by-one
    relative to the published mode contract.
15. **UnpackChunk wrapper drops the a1 save** — it relied on
    the decoder preserving a1's role; since the decoder uses a1
    as its output cursor the save was useless anyway.  No
    behavioral change.
16. **AllocMem flags byte = 1** (MEMF_PUBLIC) vs 0 in 1.06 —
    only difference: memory shows in public lists; on 1.x-3.x
    MEMF_PUBLIC is bit0 = same pool.  Cosmetic.
