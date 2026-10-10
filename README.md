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

| Library | State |
|---------|-------|
| `zlib_3.2.library` | Original StormC source recovered from Aminet; all 24 LVOs resolved in OKF |
| `iffparse_40.1_WB3.1_.library` | Reconstruction in progress (`source/` builds with m68k cross toolchain) |
| all others | Binary collected; `source/` and `okf/` awaiting analysis |
