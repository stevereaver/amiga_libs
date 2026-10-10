# amiga_libs

A collection of AmigaOS `.library` binaries for reverse engineering and source
reconstruction. Each library is a self-contained unit of work: the original
binary, recovered/reconstructed source, and a knowledge bundle recording what
has been learned about it.

## Repository layout

```
libraries/
├── template.library/          # layout template — copy when adding a library
│   ├── binary/                # original binary (gitignored, not committed)
│   ├── source/                # reconstructed/decompiled source
│   └── okf/                   # knowledge bundle for THIS library
└── <name>_<ver>.library/      # e.g. zlib_3.2.library, 68040_46.5.library
    ├── binary/
    ├── source/
    ├── okf/
    └── work/                  # scratch space (gitignored)
```

- Directory names are the library name and version with non-filesystem-safe
  characters (spaces, parentheses, `.` in version strings) replaced by `_`.
  Examples: `68040_44.2_WB3.5_.library`, `xpkmaster_4.33.library`.
- ~1,480 library versions covering ~650 distinct libraries are collected here
  (system libs, xpk/XPK sublibraries, xpr transfer protocols, datatype
  support libs, CPU support libs, third-party libs, ...).

## OKF knowledge bundles

Each library's `okf/` directory is an Open Knowledge Format (OKF) bundle:
markdown concept files with YAML frontmatter forming a linkable knowledge
graph.
Conventions for this repo:

```
okf/
├── index.md          # entry point — read this first
├── log.md            # append-only work journal (newest first)
├── functions/        # one file per exported function / LVO entry
├── structures/       # library base layout, public/private structures
├── algorithms/       # compression schemes, checksums, etc.
└── findings/         # quirks, version differences, open questions
```

Seed a new bundle by copying `libraries/template.library/okf/`. See
`.devin/skills/okf/SKILL.md` for the full format and workflow rules: read the
bundle before working on a library, and update it with findings afterward.

## Toolchain

Cross-building for m68k AmigaOS uses the AmigaPorts toolchain in `/opt/amiga`
(`m68k-amigaos-gcc` v16.2, hunk-aware binutils, `ira`, `vasmm68k_mot`, `sfdc`,
`fd2pragma`, `lha`, NDK 3.x/1.3 headers). See
`.devin/skills/amiga-m68k-gcc/SKILL.md` for flags and recipes — e.g. shared
libraries need `-fbaserel -msmall-code -mcrt=library -ramiga-lib`.

## Status

Bulk reverse-engineering campaign in progress (tracked as AMIGALIBS-9 in
Plane): every library is being disassembled, its LVOs resolved, C source
reconstructed in `source/`, documented in `okf/`, and committed per library
— smallest binaries first. The per-library workflow is in
`tools/RE_WORKFLOW.md`; inconsistencies are filed as Plane cards.

| Library | State |
|---------|-------|
| `zlib_3.2.library` | Original StormC source recovered from Aminet; all 24 LVOs resolved in OKF |
| `iffparse_40.1_WB3.1_.library` | Fully reconstructed in C, builds with m68k cross toolchain |
| `version_*` (14 builds, WB1.1–45.5 + 47.2/47.3) | Fully reconstructed in C; quirks filed (buggy 1.1 Expunge, hidden FindSemaphore probe in 44+/45+, 47.x semantics reversion) |
| `mathieeesingtrans_40.6_FPU_`, `mathieeedoubbas_40.6_{FPU,040}_`, `mathtrans_40.6_FPU_` | Martin Berndt 68881/82 rebuilds reconstructed in C+asm; FPU ops + FFP/IEEE converters verified |
| `mathtrans_40.6_040_` | 68040 rebuild: full software transcendental kernels (polynomial/rational, argument reduction); 5.6 KB code region byte-identical |
| `xpkFRLE_1.1.library`, `xpkCBR0_1.1.library`, `xpkDLTA_0.1.library` | XPK sublibraries reconstructed in C; codec round-trips host-verified; encoder defects filed as Plane cards |
| all others | Binary collected; `source/` and `okf/` in progress by size order (~66/1482 done) |
