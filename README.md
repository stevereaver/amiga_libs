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
| `xpkFRLE_1.1.library`, `xpkCBR0_1.1.library`, `xpkDLTA_0.1.library`, `xpkFRLE_1.2_000_.library`, `xpkRLEN_1.3.library`, `xpkLHLB_1.1.library`, `xpkFRLE_1.0.library` | XPK sublibraries reconstructed in C; codec round-trips host-verified; encoder defects filed as Plane cards |
| `mathieeedoubtrans_40.6_FPU_.library` | Martin Berndt 68881/82 double-precision transcendentals reconstructed; vector region byte-identical |
| `ghostrider_37.2.library` | Hotkey input-handler library reconstructed in C; launcher dispatch protocol + IND_ADDHANDLER semantics decoded; quirks filed (unrelocated ln_Name, dead DELEXP close, caller-supplied VBR) |
| `patchtest_1.00.library` | SAS/C test lib reconstructed in C; per-open runtime decoded (OpenLibrary/DisplayBeep semantics) |
| `amigaflight_1.2.library` | AmigaFlight BETA debugger console I/O toolkit reconstructed in C+asm; hex-parse/format vectors + EnterAddress prompt decoded; dead duplicate routine + quirks filed (AMIGALIBS-35) |
| `xpkSLZ3_1.3_000_.library` | Froehling fastLZ-family LZSS XPK sublib reconstructed in C (64K hash + 4K chain workmem); codec round-trips host-verified; PackReset underflow + quirks filed (AMIGALIBS-36) |
| `xpkLZW3_3.3_020_.library` | Froehling 'LZ-Welsh' greedy-LZ XPK sublib reconstructed in C (512KB hash+chain workmem); codec round-trips verified; PackReset-wipes-alloc-size 512KB leak + 020+ quirks filed (AMIGALIBS-37) |
| `xpkFBR2_4.1_000_.library` | Froehling 'FastBytesRunner' multi-mode RLE XPK sublib reconstructed in C; round-trips verified + shipped tag-90/expect-100 ByteByte decode-break defect filed (AMIGALIBS-40) |
| `xpkCBR0_1.0.library` | Bilbo 'Cmp Byte Run 0' XPK sublib reconstructed in C; literal/run RLE verified (~42k round-trips); LIBF_SUMMING-as-DELEXP flag quirk + OOB peek filed (AMIGALIBS-39) |
| `xpkLZW2_2.3_000_.library` | Froehling 'LZ-Welsh' V2.3 greedy-LZ XPK sublib reconstructed in C (320KB hash+chain workmem, lazy-insert); round-trips verified; 5KB PackReset underflow -> 320KB PackFree leak + quirks filed (AMIGALIBS-41) |
| `reqattack_0.03.library` | ReqAttack requester-attack proxy reconstructed in C (SAS/C manual-init, WarpCore port+46 forwarding to intuition EasyRequest/BuildEasyRequest); double-Permit + decorative-RomTag defects filed (AMIGALIBS-42) |
| `xpkFBR2_3.1.library` | Froehling 'FastByteRun' three-mode RLE XPK sublib reconstructed in C; 5676 host round-trips verified + windowed-scanner OOB-emit, tail-drop and unsafe-decoder defects filed (AMIGALIBS-43) |
| `xpkILZR_1.5_000_.library` | Jose Reanu 'Incremental LZ-Renau' hash-chain LZSS XPK sublib reconstructed in C (absolute-position match tokens, dynamic position width); 3647 host round-trips verified + latent chain-overflow, dangling-PackFree and OOB-read defects filed (AMIGALIBS-44) |
| `xpkrlen_1.1.library` | xpkRLEN 'Run Length' RLE XPK sublib reconstructed in C (two-hunk SAS/C copy+fixup init, long-address functab); 19701 host round-trips verified + unchecked-run-emit and boundless-decoder quirks filed (AMIGALIBS-45) |
| `services_37.10.library` | Commodore nipc service registrar reconstructed in C; SvcControl entity sequence + SvcFormat RawDoFmt decoded; undocumented nipc LVOs + init-alert quirk filed (AMIGALIBS-38) |
| `cxb_37.1.library` | Captain Crossbones requester toolkit reconstructed in C (SAS/C per-task contexts, dos+intuition+graphics); EasyRequestArgs + file-info/multiplier vectors decoded; half-cleared context table + overlapping flags defects filed (AMIGALIBS-46) |
| `mcpsupport2_5.2.library` | ALiENDESiGN MCP support lib reconstructed in C; file-loader, CLI-name getters and recursive AmigaDOS wildcard matcher (21 host cases pass); version-mismatch + expunge-leak defects filed (AMIGALIBS-47) |
| `warpHW_1.0.library` | WarpUp BlizzardPPC hardware driver reconstructed in C+asm; register-poke sequences + embedded PPC blob byte-faithful; functional-equivalent (SAS/C 3-hunk far-data) noted (AMIGALIBS-48) |
| `shutdown_2.3.library` | Shutdown-hook registry reconstructed in C (semaphore-guarded callback list, dos+utility per context); Register/Unregister/FireShutdown decoded; SAS/C manual-init far-data functional equivalent |
| `xpkDMCB_1.1.library` | Froehling 'Dynamic Markov Compression' DMC arithmetic-coding XPK sublib reconstructed in C (68020+68881-gated, 2MB state-cloning Markov model); 3866 host round-trips verified + unreachable-clone and bound quirks filed (AMIGALIBS-50) |
| all others | Binary collected; `source/` and `okf/` in progress by size order (~89/1482 done) |
