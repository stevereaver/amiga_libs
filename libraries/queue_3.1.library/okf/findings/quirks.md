# queue.library 3.1 — quirks & rebuild notes

1. **Overlapped instruction immediates (twice, both in init):**
   - `h0+0x7a`: `cmpiw #0x1cd9,d0` (`0c 40 1c d9`). The immediate word
     `1cd9` is itself `move.b (a1)+,(a6)+` — the init byte-copy loop
     branches *into* the cmpiw immediate at h0+0x7c. The cmpi only runs
     once on entry to set up flags; the loop body is the hidden move.b
     plus `subql #1,d1`/`bccs`.
   - `h0+0xb8`: `cmpiw #0x200d,d0` (`0c 40 20 0d`) hides
     `move.l a5,d0` at h0+0xba — the shared init epilogue: the
     `beqs` at 0xb4 jumps mid-instruction to return the libbase, while
     fall-through executes `moveq #0,d0` (failure path) and the cmpiw
     degenerates to a harmless compare.
   Reproduced in gas via `bccs label+2` / `beqs label+2` on the cmpiw
   labels.

2. **Descending-order RELOC32 groups.** Every relocation group lists
   its patch offsets in descending order (h0: `0a 06`, `86 74 1a`,
   `5a 34 16 12`; h2: `30..00`). SAS/C's linker emitted relocs in
   reverse reference order. fixup.py rewrites the groups verbatim.

3. **Two CODE hunks.** hunk2 is tag 0x3e9 (CODE) although it contains
   only the functab + strings — SAS/C put its "far" link tables in a
   code hunk. The amiga ld cannot emit two code hunks, so the build
   links one DATA hunk and fixup.py splits it at 0x20.

4. **DATA hunk is an InitTable overlay.** rt_Init points at hunk1+4,
   i.e. the DATA record doubles as {dsize,functab,datatab,initfn};
   hunk1+0 is a pad long. The initfn then re-copies the first 28 bytes
   of that same template into lib+48 (overwriting g+20/g+24 with
   SysBase/QueueBase afterwards).

5. **Generic pointer-rebase loop with an empty table.** After the
   28-byte copy the init code reads a fixup count at template+0x1c
   (zero) and would walk a table of offsets rebasing stored pointers —
   `*dest += lib+48`. The table is empty; the code is dead but fully
   present (SAS/C runtime remnant).

6. **`lea abs.l` for small constants.** Version (3), revision (1) and
   the copy count (7) are loaded with absolute-long `lea`
   (`43f9 0000000x`) — no relocation, unusual codegen.

7. **Entry stub doubles as LVO -24.** The `moveq #0,d0;rts` at hunk0+0
   (safety rts in front of the RomTag) is also the 4th functab entry —
   the reserved vector returns 0.

8. **`subqw` vs `subaw` frame markers.** SAS/C uses subq where it can:
   `subqw #8,sp` (`514f`, quick-field 0 = 8) for 8-byte frames and
   `subqw #4,sp` (`594f`) for 4-byte ones, but `subaw #12/#16`
   (`9efc`) for the larger ones — easy to mistranscribe.

9. **Union overlay in QueueHandle.** The listener's embedded marker
   MinNode @28 sits on top of the sender's qhs_ReplyList lh_Tail/
   lh_TailPred — the shipped header documents `qhl_MinNode` as "same
   as qm_MinNode"; intentional aliasing, not a bug.

10. **Uninitialized stack read in QClose.** When neither the marker
    nor qhl_Message is set, `next` (sp+28 local) is read uninitialised
    — faithfully reproduced; harmless since it only feeds a NULL test.

11. **bsr encodings.** The compiler used word-form `bsr.w` almost
    everywhere (even where a byte displacement would fit, e.g. the
    `6100 000c` at 0xf2 into Close), but emitted a genuine short
    `bsrs` (`6184`) at 0x242 in ReplyQMessage. All forced via `bsrw`
    mnemonic where needed.

12. **Dead padding.** `0000` word at h0+0x1e (EndSkip target, aligns
    initfn), `4e71` nops at 0x156 and 0x996 (4-byte function
    alignment), `"#$"` (0x2324) tail bytes at hunk2+0x5a — probably
    the first two chars of a truncated "$VER:"-style string remnant
    left by the linker after the 0x34-byte-aligned string block.

13. **idstring has no `$VER:` prefix** — it is literally
    "queue.library 3.1" (the source carries the full
    "$VER: queue.library 3.1 (12-3-96)" only in the gcc branch).
