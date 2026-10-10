---
name: okf
description: Maintain per-library Open Knowledge Format (OKF) bundles in this repo. Scan a library's okf/ bundle before working on it, and update the bundle with findings afterward. Each subdirectory of libraries/ has its OWN okf/ bundle — there is NO root-level okf.
---

# OKF in this repo

This repo collects Amiga `.library` binaries for reverse engineering. Each library
directory is a self-contained unit of work:

```
libraries/
├── template.library/          # layout example — copy this when adding a library
│   ├── binary/                # original binary (gitignored)
│   ├── source/                # reconstructed/decompiled source
│   └── okf/                   # knowledge bundle for THIS library
└── <name>_<ver>.library/
    ├── binary/
    ├── source/
    └── okf/
```

**There is no root-level `okf/`.** Every bundle lives at
`libraries/<library dir>/okf/` and documents only that library. When working on a
library, its bundle is the one that matters — don't scan other libraries' bundles
unless the task spans them.

## What OKF is

Open Knowledge Format (OKF v0.1) is a vendor-neutral way to represent knowledge as
a directory of markdown files. Each file is one **concept** with YAML frontmatter
(the structured, queryable part) and a markdown body (everything else). The file
path is the concept's identity. Concepts cross-link with normal markdown links,
forming a graph. The only required frontmatter field is `type`.

## Bundle conventions

```
okf/
├── index.md          # entry point — always read this first
├── log.md            # chronological journal of findings/changes
├── functions/        # one file per function/LVO entry analyzed
│   ├── index.md
│   └── Examine.md
├── structures/       # data structures, library base layout
│   ├── index.md
│   └── LibraryBase.md
├── algorithms/       # compression schemes, checksums, etc.
│   ├── index.md
│   └── RLE.md
└── findings/         # quirks, version differences, open questions
    ├── index.md
    └── ...
```

- `index.md` files give progressive disclosure: the agent reads the top index,
  then descends only into relevant categories. Keep them short — a list of links
  with one-line descriptions, not a dump.
- `log.md` is append-only: newest entry at top, one line per work session
  (date, what was analyzed/found, follow-ups).
- Subdirectory names are the producer's choice; the categories above are this
  repo's convention for a typical library. Drop categories that don't apply and
  add ones that do (e.g. `resources/`, `registers/`).

## Concept document format

```markdown
---
type: Function            # required — everything else is optional
title: Examine
description: Examines a file/directory and fills a FileInfoBlock.
lvo: -30                  # repo-specific fields are fine
tags: [dos, files]
timestamp: 2026-10-10T14:30:00Z
---

# Signature
...

# Notes
Calls [Lock](./ExamineLock.md) internally...
```

Suggested `type` values for this repo: `Library`, `Function`, `Structure`,
`Constant`, `Algorithm`, `Resource`, `Finding`, `Runbook`. Consistency matters
more than the exact vocabulary — reuse types already present in the bundle.

- `resource`: use it to point at evidence — e.g. `binary/xpkHFMN.library` or a
  source file path relative to the library directory.
- Cross-links: relative markdown links between concept files
  (`[Examine](../functions/Examine.md)`).

## Workflow

1. **Before starting work on a library**: read `libraries/<lib>/okf/index.md`.
   Follow links into only the categories relevant to the task. If the bundle is
   empty or missing, seed it from `libraries/template.library/okf/`.
2. **During work**: treat the bundle as prior knowledge — build on it, correct it
   if the binary disagrees, don't re-derive what's already recorded.
3. **After making changes or discoveries**: update the bundle — new/amended
   concept files, refreshed `index.md` files, and a `log.md` entry. The bundle
   should let a future session resume without re-analyzing the binary.

## Rules

- Never create or use a root-level `/okf` — bundles are per-library only.
- Never document a library in another library's bundle; shared observations that
  genuinely span libraries may cross-link to a sibling bundle with a relative
  path (e.g. `../../xpkHFMN_1.36_020__.library/okf/...`), but keep it rare.
- One concept per file; filename = concept identity (keep stable, rename only
  with link updates).
- Write what the binary/source shows — mark speculation as open questions in
  `findings/` rather than asserting it.
- `binary/` is gitignored; `okf/` is committed. Concepts must carry enough
  context to stand alone without the binary.
- Timestamp frontmatter entries with ISO 8601 UTC.
