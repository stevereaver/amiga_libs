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
| `fastlayers_40.48.library` | Kneer/Abt 'FastLayers' layers.library accelerator reconstructed in C; ROM->RAM module relocation + internal-call rewrite + 5 SetFunction patches (cheap layer create, SMART->SIMPLE move/size) decoded; dead-flag and functab-shift quirks filed (AMIGALIBS-51) |
| `mathffp_36.5.library` | C= FFP math library 36.5 (MC68343-derived firmware) reconstructed in C; all 16 vectors resolved, word-offset functab + packed RomTag preserved; 1,649,955 host differential cases with 0 mismatches vs bit-exact oracle; shipped quirks filed (AMIGALIBS-52) |
| `xpkBLZW_3.3.library` | 'Bryan's turbo-charged LZW' XPK sublib reconstructed in C; 9-15-bit hash-chain LZW codec, byte-exact pack vs oracle + full unpack round-trips; hash-table-OOB and divu-divisor quirks filed (AMIGALIBS-53) |
| `explode_4.6.library` | 'Executable exploder' V4.6 decruncher+relocating loader reconstructed in C; LoadSeg hook install + inline-data Explode entry + tail-jump decoded; dead-end-alert and never-expunge quirks filed (AMIGALIBS-54) |
| `i2c_40.0.library` | Apollo I2C bus driver reconstructed in C; 9-clock bit-bang engine ($de0080/$de0081), CIAA-timed edges, I2CDELAY env init, packed error strings decoded; dead-status and in-code-hunk-buffer quirks filed (AMIGALIBS-55) |
| `bfbplayMED__1.0.library` | Teijo Kinnunen MED/OctaMED player wrapper reconstructed in C; tag-driven InitModule (file/handle/memory sources), medplayer.library vector map decoded; uninit-clamp and wild-free defects filed (AMIGALIBS-56) |
| `xpkSLZ3_1.1.library` | Froehling 'SpeedLZ' LZ77 XPK sublib reconstructed in C (256KB 2-byte-context LRU match table, 12-bit-off/4-bit-len tokens); 2000 host round-trips verified + seglist-store, packmem-descriptor and null-vector quirks filed (AMIGALIBS-57) |
| all genfunctab-based reconstructions (43 libs) | Systematic functab defect repaired: undersized two-pass stubs + RELRELOC16 inline diffs had placed every vector offset inside mid-function code; all stubs resized, mathffp converted to two-pass, every vector re-verified against linked symbols (AMIGALIBS-58) |
| `xpkLZW4_4.3_020_.library` | Froehling 'LZ-Speeder' lazy hash-chain LZ XPK sublib reconstructed in C (512KB head+chain workmem, MSB-first flag longs, [-dist:u16][len-3] tokens, mode-scaled lazy budget); 5000 host round-trips verified + tail-overread defect filed (AMIGALIBS-59) |
| `epu1.library` | 'Easy Pack Utility' lh.library front end reconstructed in C; EpuPack/EpuUnpack ctx+block plumbing, AutoRequest RETRY/CANCEL retry dialogs decoded; stale-chain, upside-down-dialog and a0-Remove quirks filed (AMIGALIBS-60) |
| `xpkSMPL_1.1.library` | Froehling dynamic-Huffman + delta-precoding XPK sublib reconstructed in C (binary trie + 10-bit fast table, byte-sized bitspace accounting); byte-exact stream verification + critical len-0 accumulator-wipe desync defect filed — streams only valid when all 256 deltas occur (AMIGALIBS-61) |
| `rexxapp (Jan 91)` | ARexx application-host interface lib ("dissidents Jan 91") reconstructed in C — old-style non-AUTOINIT layout, A5-carried context, 3 distinct callback ABIs; fold-boundary + result-clobber quirks filed (AMIGALIBS-62) |
| `Ted_1.0.library` | Shared-state/method-dispatch shim reconstructed in C — 20 LONG vectors over code-hunk globals + context method calls (AMIGALIBS-63) |
| `cachefile_1.67.library` | Ralph Schmidt disk-file cache + embedded CacheFile_Notify daemon (CreateNewProc into own hunk) reconstructed in C — 11 vectors resolved; dead-expunge, nested-sem-deadlock and V39-only-LVO defects filed (AMIGALIBS-64) |
| `xpkLZW5_5.3_020_.library` | Froehling 'LZ-Speeder' tiered-token LZ XPK sublib reconstructed in C (2-bit flags: short/med/long tiers, 16 items/long, mode/34 lazy budget); byte-exact encoder vs independent model + ~20KB PackReset heap-clobber and self-corrupting tier-boundary tokens filed (AMIGALIBS-65) |
| `memorymanage_1.01_030_.library` | 68030 PMMU memory-management lib reconstructed in C+asm — 3-level page tables (128x32M/128x256K/64x4K), PMMU supervisor bodies (pmove/pflusha/ptestr) byte-exact, 11 vectors resolved; 7 defects filed (no CPU check, stale ctx, no locking) (AMIGALIBS-66) |
| `xpkTDCS_1.5_020_.library` | Froehling 'Sarnath's Doom' LZSS-family XPK sublib reconstructed in C — the original tiered-token codec (len-3 fields, flag-11 terminator); byte-exact streams vs model; also fixed LZW5 PackReset fill count (70,577 not 88,217) (AMIGALIBS-67) |
| all others | Binary collected; `source/` and `okf/` in progress by size order (~105/1482 done) |
