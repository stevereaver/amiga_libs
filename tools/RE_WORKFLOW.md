# Library reverse-engineering workflow

Standard pipeline for every `libraries/<name>_<ver>.library/` directory.
Exemplar: `libraries/iffparse_40.1_WB3.1_.library/` (complete) and
`libraries/zlib_3.2.library/` (recovered source). Follow them for style.

## Phase 1 — Inspect the binary

Work products go in `work/` (gitignored). Never copy the binary or
disassembly dumps into `source/` or `okf/`.

1. `B=$(ls libraries/<dir>/binary/*)` — record sha256, size, `$VER:` string,
   Amiga `$VER`/`version` strings, embedded copyrights, hunk layout
   (`/opt/amiga/bin/m68k-amigaos-objdump -h`, `-x` for relocs).
2. Disassemble: `/opt/amiga/bin/ira -M68000 <bin> > work/<name>.asm` (use
   `-M68020`/`-M68040` when the library requires newer CPUs — e.g. 680x0 CPU
   support libs). `m68k-amigaos-objdump -d` as a cross-check.
3. Parse the resident header: `moveq #-1,d0;rts` entry, RomTag (0x4AFC),
   RT_NAME/RT_IDSTRING, RTF_AUTOINIT flag, and the InitTable (dataSize,
   function table, data init, initRoutine). Decode the function table:
   word offsets relative to table start, or absolute longs, terminated by
   -1. That gives the ordered LVO list (-6 Open, -12 Close, -18 Expunge,
   -24 ExtFunc/reserved, user functions from -30).
4. Name the functions: check `/opt/amiga/m68k-amigaos/ndk/lib/fd/` and
   `fd13/` for a matching `*_lib.fd`; also `strings` for exported names,
   xpk/xpr family docs, error text. Unnamed functions get descriptive
   names (`Func_XXXX` by table offset) — record uncertainty in findings.

## Phase 2 — Reconstruct `source/`

Goal: C source that builds a loadable HUNK `.library` with the same
RomTag, name/id strings, vector order and semantics.

- Skeleton header `.s` with the RomTag + InitTable + strings, modelled on
  `iffparse_lib.s`. Hand-written `.s` sources ARE allowed (needed for the
  header/vectors); `*.asm` IRA dumps are NEVER committed.
- `Makefile`: copy the iffparse pattern — two-pass link to generate the
  AUTOINIT function table via `genfunctab.py` (copy and adapt the script).
- Function calling convention: register args `__asm("a0")` etc. `__saveds`
  on exported functions when the lib is baserel (most are not — check the
  InitTable for the data model: many small libs use absolute data).
- `make` must succeed with only warnings, producing `<name>.library`.
- Sanity-verify: vector table order matches, name/id/version strings
  match, RomTag fields match, code hunk contains equivalent logic.
- Where a function genuinely cannot be written in C (MMU/coprocessor
  control, CPU-patch machinery, pure-asm idioms), use a small `.s`
  source — still no `.asm` dumps. If a library is fundamentally
  asm-bound, reconstruct what is feasible and mark status PARTIAL with
  the reasons documented in `okf/findings/`.

## Phase 3 — Populate `okf/`

Seed from `libraries/template.library/okf/` if the bundle is empty.
Per the okf skill conventions:

- `index.md` — type `Library`, version string, binary facts (size, sha256,
  hunks), status line, category links.
- `functions/` — one concept per LVO entry (index -6 .. lowest), type
  `Function` with `lvo:` frontmatter, signature with register args,
  semantics, internal calls.
- `structures/` — library base layout, hunk map, InitTable, public structs.
- `algorithms/` — only when the lib implements one (compression etc.).
- `findings/` — quirks, version differences, deviations, open questions,
  and anything that could not be reconstructed faithfully.
- `log.md` — one entry per work session, newest first.

## Phase 4 — Report

Return, per library: status FULL | PARTIAL | FAILED, binary sha256, LVO
count resolved, build result, and a list of inconsistencies/deviations
(these become Plane cards). PARTIAL/FAILED must say exactly what remains.

## Rules

- Only modify files inside the assigned `libraries/<dir>` directories.
- Do not run any `git` commands — committing/pushing is handled centrally.
- Keep all binaries and `*.asm`/`*.o`/`*.nm` dumps inside `binary/`/`work/`;
  they are gitignored, do not reference-copy them into tracked dirs.
- Record only what the binary shows; speculation goes in `findings/` as
  open questions.
