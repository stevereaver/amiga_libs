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
| `explode_5.6.29.library` | 1991 "Executable Explode Wedge" — patches dos LoadSeg to inflate packed executables in place; wedge stub + -30 jsr+inline-data API + backward bit-reader LZ decoder coroutine transcribed asm (byte-identical), lifecycle/wedge-install in C; 8 quirks filed (AMIGALIBS-68) |
| `dsp3210_2.1.library` | 2021 AT&T DSP3210 COFF loader — manual MakeLibrary init; -30 validator + -36 reloc engine (verbatim asm, byte-identical; types 44/46/47/28/34/35, UNDEF resolved vs caller-frame exttab) + -42 file loader (Lock/Examine/Read, 0x32102011 descriptor, CachePostDMA) + -48 free in C; 7 defects filed (AMIGALIBS-69) |
| `xpkSMPL_1.2_000_.library` | Froehling 'Sample Huffman V1.2' XPK sublib — reworked 2013 codec vs 1.1: delta histogram -> sorted-list Huffman (before-equals insert, roxr MSB-first codes) -> nibble length table; unpack = 4-byte-node trie + 1024-entry 10-bit fast table; encoder byte-exact vs model, 23/23 round-trips; inlen-0 crash, len>=31 nibble-format corruption, trie/table overflow overlap filed (AMIGALIBS-70) |
| `xpkSMPL_1.0.library` | Froehling SMPL 1.0 (1993) — first of the Huffman-delta family; same codec flow as 1.2 with 1.1-style layout (24-B pointer nodes, byte lentab, len>=15 -> 8-bit len-31 escape, separate pack/unpack allocs, Sub[0] cleared on free); 10 vectors resolved incl. -24/-48 dedicated stubs; byte-identical streams to verified 1.2, 23/23 round-trips (AMIGALIBS-71) |
| `bfbplayPSID_1.0.library` | bfb player-module wrapper on playsid.library (Sundell/Birk) for PSID SID tunes — tag-driven InitModule (file/handle/memory), 80B session, playsid vector map decoded; StopModule's odd A5-arg ABI + wild-free/stale-tag defects filed (AMIGALIBS-72) |
| `xpkHFMN_1.4_020_.library` | Huffman 020+ V1.4 (Hauner) — heap-built dynamic Huffman XPK sublib; preorder tree emit + 10-bit fast-table decoder; encoder byte-exact vs independent model incl. the ADDX pad-bit quirk; -24 vector wraps onto the entry stub (AMIGALIBS-73) |
| `explode_7.0.library` | 1996 explode wedge 7.0 (Struijk/Brouwer, 040/60 fix by Calkowski) — patches dos LoadSeg AND NewLoadSeg (-150/-768) with twin in-hunk stubs; dual signature check; same LZ+Huffman coroutine as 5.6.29 with fully inlined hunk-walks/ring-reads + movem bursts + unconditional CacheClearU; verbatim asm byte-identical, lifecycle in C; V6.0-vs-7.0 datatab mismatch, fails-open init, blind vector restore filed (AMIGALIBS-74) |
| `xpkHUFF_1.0_000_.library` | Zimmerman 'Huffman V1.0' XPK sublib — sorted-list Huffman over raw bytes (no delta) + optional password layer (0xABADCAFE marker / chained pwhash + XOR-ADD descramble, descriptor flag 0x2000); 4B-node trie + 1024-entry 10-bit fast table decoder; encoder byte-identical vs independent model incl. >16-bit split emit, password hash 4D840818 verified; dead 0xABADCAFE offset-0 check, descramble over-read, 0xC0 hash contamination, dbf-length wraps filed (AMIGALIBS-75) |
| `xpkZENO_1.2_000_.library` | Tuenkler 'ZENO V1.2' XPK sublib — hash-probed LZW (h=(byte<<(bits-8))^(prev+1), per-width rehash moduli, 9->12/13/14-bit codes, 0x100 EOI / 0x101 adaptive reset on 1024-byte compression deltas, password hash header); encoder byte-identical vs independent model incl. 120KB reset-path stream; header + descriptor byte-identical; -17/-32/-7 paths verified; top-code-never-issued, unreachable 15-bit modulus, no InLen bound filed (AMIGALIBS-76) |
| `i2c_40.1.library` | PFC8584 I2C bus driver (Zorro, FindConfigDev mfg 0x1389/prod 15): 14 vectors — probe/reset/delay/write/read/errtext/shutdown/reenable; polled BB/AL/LRB with VBlank int-5 timeout; ENV:I2CDELAY/I2CXTAL via dos.library v36; data region byte-identical modulo relocs, I2CIntr byte-identical; EXT.W errtab sign-extension bug (7 entries point into the functab), dead CIA code + dead intr node filed (AMIGALIBS-77) |
| `memorymanage_1.01_040_.library` | 68040 MMU memory-management lib (the 030 PMMU lib's 040 sibling) reconstructed in C+asm — 3-level page tables (128x32M/128x256K/64x4K) demand-allocated with trailer-node freelist, base-preserving child fills; supervisor bodies (MOVEC URP/SRP/DTT/ITT/TC + PFLUSHA, PTESTW) in asm; 11 vectors resolved; header byte-identical; 12 defects filed incl. garbage-SRP install (FreeVec return patched into SRP/DTT1) and detach-restores-patched-profile (AMIGALIBS-78) |
| `bfbplayGMOD_1.0.library` | bfb GMOD module player (Bryan Ford) — module image is itself 68k code (jump-table calls at buf+20 play/+24 stop/+40 tick/+64 songs); CIA timer ICR interrupt (ciaa/ciab.resource, period 0x3781) -> exec Cause -> softint -> tick; tag-driven InitModule (file/handle/mem, CHIP modbuf), SetSubsong 0-based; self-modifying ciaa->ciab patch + empty GetInfo filed (AMIGALIBS-79) |
| `xpkFAST_1.2_000_.library` | von Roques 'FAST V1.2' XPK sublib (WOOP/LZRW++) — LZ77 4K-window codec: literals forward + ctrl/token words backward, sentinel-in-X addx bit stream; dual packers (speedy 16K-hash greedy mode<79, crawling 64K-hash+chain mode>=79); both packers byte-identical vs independent models, decoder modeled on addx sentinel; crawler-can't-emit-len18, stale-chain-after-Reset, signed-off quirks filed (AMIGALIBS-80) |
| `screennotify_1.2.library` | screennotify.library 1.2 — intuition screen/WB event notifier: 4 SetFunction patches (OpenScreenTagList/CloseScreen/CloseWorkBench/PubScreenStatus), 'scn service process' worker proc, 3 semaphore-guarded client lists w/ synchronous PutMsg+ack; 0x1b0 position-dependent patch image w/ PC-rel shadow refs into lib base; images byte-identical; defects filed (AMIGALIBS-81) |
| `explode_6.0.64.library` | Executable Explode Wedge V6.0.64 — dual dos wedge (LoadSeg -150 + NewLoadSeg -768 on exec>=37), raw slot-byte save/restore, foreign 'moveq;bra' wedge tolerance, "ed explode.libra" prefix signature; backward-bitstream LZ/Huffman in-place decruncher w/ integrated hunk reloc; 0x49e verbatim block byte-identical; 8 defects filed (AMIGALIBS-82) |
| `xpkRDCN_2.4_000_.library` | Sjöberg 'Ross Data Compression V2.4' XPK sublib — LZ+RLE hybrid: 16-token BE ctrl words, MATCH2B/3B (dist+3 12-bit) + RLE2B/3B (+3/+19, caps 18/4114); dual packers (speedy 4K-hash greedy mode<=79, crawling 64K-hash+8K-chain lazy-insert mode>=80); both packers byte-exact vs independent models, decoder validated; dist1-2 underflow, addr-aliased chain, stale-links quirks filed (AMIGALIBS-83) |
| `genesiskey_45.3.library` | Genesis TCP/IP stack generated registration-key lib — 3-hunk (code+data+bss), RomTag w/ rt_Init=data-hunk InitTable offset (custom loader), init gated on AttnFlags&AFF_68020, embedded serial "454545"@+0x20 + "AmigaOS 3.9"@+0x120 exposed as offsets via vectors -66/-78, -54 genesis/bsdsocket probe; RomTag+data hunk byte-identical modulo relocs (AMIGALIBS-84) |
| `xpkBLZW_3.4_000_.library` | Bryan Ford 'BLZW V3.4' XPK sublib — Unix-compress-style LZW: 9-15-bit MSB-first codes (256=end/257=clear/258=width++), 6-byte hash entries w/ unmasked ((c<<(bits-8))^pfx)*6 hash, tables 641-40961, ratio-checkpoint dictionary CLEAR, V-flag marker-chain decoder; packer byte-exact via independent decoder (200KB, 19 bumps, 3 CLEARs), decoder byte-exact on 21 independent encoder streams; emit-bound-reads-wrong-slot, inlen<32 clear underflow, single-step width bump filed (AMIGALIBS-85) |
| `xpkhfmn_1.28_020__.library` | Hauner 'dyn. Huffman.020+ V1.28' XPK sublib — ancestor of HFMN 1.4: same heap-built dynamic Huffman + preorder tree stream (pack output byte-identical to verified 1.4), but LONG-offset functab and a code-GENERATING decoder (LAB_0039 compiles the tree into add.l/bcc.w nodes + moveq/move.b/dbf leaves in workmem, then jsr's it; 030+OS2.0 CacheClearU); round-trips verified incl. depth-19 refill path; no-emit-bounds, unconditional-expunge, gen/stack overlap quirks filed (AMIGALIBS-86) |
| `xpkHFMN_1.4_000_.library` | Huffman V1.4 (Hauner) 68000 build — same dynamic-Huffman codec and stream as the verified 020 sibling (pack output byte-identical on 10 inputs), no AttnFlags CPU gate, 'Huffman V1.4' longname, slower advertised speeds 0x81/0xc0; word-offset functab, -24 wraps onto the entry stub (AMIGALIBS-87) |
| `pointer_33.2.library` | NuPointerLibrary 33.2 (5 Jan 1991) busy-pointer lib — loads SYS:Prefs/presets/BusyPointer.ilbm via iffparse at init, embedded 16x16 CHIP-bitmap fallback; 3-hunk CODE/CHIP/DATA reproduced w/ data-hunk InitTable + fixup list; SetPointer/LoadSpec/FreeSpec + 19 LVOs resolved; host-sim all-8-scenarios pass; uninit-'iff', NULL-spec writes, bodysize=0 quirks filed (AMIGALIBS-88) |
| `xpkSQSH_1.2_020_.library` | John Hendrikx 'Squash 020+ V1.2' XPK sublib — LZ+delta codec for 8-bit sound: signed-delta literals at adaptive 2-8-bit widths (deltok/widtab slot codes), litpress>7 marker inversion ('00' match escape), bfffo width select, dual-slot hash-chain match find; 59/77 sweep round-trips byte-exact (rest faithful -17 budget rejects); lookahead-overrun, stale-carry semantics, PackMem 0x2080-vs-0x22080 filed (AMIGALIBS-89) |
| `xpkLZBS_2.1_000_.library` | Niels Froehling 'LZStreamer/BSI Bitstream Packer V2.1' XPK sublib — LZSS: LSB-first tokens ('0'+8b literal, '1'+len-2(8b)+dist, '1'+0+12b run escape ≥21 lits), dist width via min(pos,window) power-of-2 table, mode→2-13-bit window, 65536-head hash + window ring chain (h=(b0<<8)|((b1+b2)&0xff), dist<<16|len reg packing); 74 host round-trips + 40 independent-decoder streams byte-exact; stale-Sub, mode-change realloc gap, stream-trusting decoder filed (AMIGALIBS-90) |
| `xpkMASH_1.16.library` | 'Mashiner MASH V1.16' XPK sublib — LZ77-family, 32KB window, lazy match + next-byte filter, hash-chain (b1<<shift|b0) w/ dynamic 0x20000→0x800 alloc, MSB-first bits sharing one stream w/ literals ("2 mixed streams"), `1<<(mode/10)` skip budget; FATAL len2+dist≥512 token corruption reproduced bit-exact (V1.98 'good packer' is the fix), sign-ext chain aliasing, 0x100B clear underwrites filed (AMIGALIBS-92) |
| `xpkmash_1.26.library` | 'Mashiner MASH V1.26, good packer' XPK sublib — same codec/format as 1.16 (byte-compatible tables + tokens); impl deltas: `inlen-10` bound, alloc2 tries 0x20000→0x2000 (5), chain table left UNINITIALISED (only `chain[in.w]=0xffff` prime), whole-byte bit-emitter + decoder byte-load fast paths; descriptor byte-exact incl. mode record `7ff8` tail; len2/dist≥512 carry-drop, delta-0 chain self-loop HANG on >64KB inputs, below-input window reads, garbage-chain nondeterminism filed (AMIGALIBS-93) |
| all others | Binary collected; `source/` and `okf/` in progress by size order (~130/1482 done) |
