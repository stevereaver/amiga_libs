# config.library — quirks, inconsistencies, defects

## Hunk-format quirks

1. **DATA hunk size mismatch.** The hunk table (HUNK_HEADER) allocates
   hunk 1 as `0x56` longwords (344 B) but the hunk's own size field says
   `0x55` (340 B). The loader reads 340 B and leaves the last longword
   zeroed. `fixup.py` rewrites the table entry after link.

2. **Non-ascending RELOC32 offsets.** h0's single group (-> hunk1) is
   scrambled: `0x486 0x2e8 0x2aa 0x8 0x6b2 0x62c 0x7de 0x77e 0x754
   0x73c 0x706 0x6f0`. h1's self-group is also scrambled:
   `0xa6 0xc6 0xb2 0xde 0xb6 0xaa 0xba 0x11c 0x120`. The linker emits
   sorted records; `fixup.py` rewrites both groups verbatim.

3. **RomTag + InitTable + functab live in the DATA hunk**, not the CODE
   hunk (AUTOINIT works fine regardless — the linker just happened to
   place them there; all their internal pointers are h1 self-relocations
   except `initfn`/functab entries which relocate to hunk 0).

4. **Version inconsistency.** RomTag `rt_Version=3` and datatab
   `lib_Version=3`/`lib_Revision=0`, but `lib_IdString` claims
   `"config 1.0 (12.10.96)"` — i.e. the installed library is version
   3.0 while calling itself 1.0.

## Code-level quirks / defects

5. **`GetNum` ignores `StrToLong`'s return value.** It returns the
   result cell unconditionally (`movel a5@(-44),d0` after the call), so
   an unparseable file value returns whatever garbage occupied that
   stack slot — observed in the oracle as the *previous* call's result
   (returned `1234` for a file containing `k = xy`). The default path
   only works because the formatted `"%ld"` default is fed back through
   the parser.

6. **`SetStr` rewrites the whole file** — reads every line into an
   AllocVec'd linked list, then reopens with `MODE_NEWFILE` and streams
   all lines back. Write failures are never checked (VFPrintf return
   ignored) and it returns 1 regardless once the rewrite opens.

7. **Blank-line injection.** Stored lines are echoed with the
   `d6 ? "\n" : ""` separator where d6 is the *line index*, but the
   separator is only prepended on `[`-header writes — so every section
   header after the first line acquires a leading blank line on rewrite
   (`...\n\n[misc]\n...`), whether or not the original file had one.

8. **Unconditional last-byte strip.** Both readers do
   `line[strlen(line)-1] = 0` after FGets assuming the byte is `\n` —
   a final line without a trailing newline loses its last character
   (affects both matching and the rewritten file).

9. **Exact `" = "` separator required.** Keys only match lines of the
   exact form `key = value` (single spaces). `key=value` or
   `key  =  value` are not recognised by GetStr and are echoed verbatim
   by SetStr (creating a duplicate key line rather than replacing).

10. **Prefix matching for sections.** `strnicmp(line+1, section,
    strlen(section))` — a section header `[preferences]` matches a
    query for `prefs` (prefix only, the `]` position is not checked
    against the name length). Keys use the same prefix test but then
    require the literal `" = "` immediately after, which is safe.

11. **Blank lines are silently dropped** by SetStr's slurp: after the
    last-byte strip, `strlen<=0` loops back to FGets without storing —
    so blank lines never enter the list and vanish on rewrite (the
    `\n`-separator before `[`-headers partially re-synthesizes them).

12. **Key inserted at section end is not marked written.** Inside
    SetStr's header branch, when leaving the target section it emits
    `key = value` before the new header but does not set `d4` — if the
    same section name appeared a second time later in the file the
    pending-insert logic could run again.

13. **Dead code / unused deps.** `intuition.library` and
    `graphics.library` are opened (v37) and their bases stored but no
    code references them — pure SAS/C boilerplate. There is a second,
    unreachable null stub at h0+0x6ec (not in the functab), and the
    tail of h0 (0x948..0x963) holds register-save shims.

14. **`_sprintf` reads SysBase from absolute `$4`** (`moveal 4,a6`)
    rather than the small-data exec cell — harmless but unusual
    inconsistency vs the `_ex_*` wrappers.

15. **Oracle hazard:** `expunge` calls `exec Remove(lib)` on the lib
    node — a harness that doesn't link the node into a list first will
    have Remove write through `ln_Pred==0`/`ln_Succ==0`, scribbling on
    absolute addresses 0 and 4 (which kills `moveal 4,a6` users like
    `_sprintf`). Behaviourally correct on a real system where the lib
    is always in `exec->LibList`.
