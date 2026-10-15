# 68030.library 40.1 (MMU) — RE log

- Started from the completed 68020 40.1 sibling
  (`68020_40.1_MMU_`).  Byte-diffed the code hunks:
  1320→1324 B; ~everything identical modulo an +8 region
  shift and four genuine deltas.
- CPU gate (init code+0x54): `btst #3` (AFF_68040) → fail,
  `btst #2` (AFF_68030) required — exactly-a-68030.
- super_coldreboot (region+0x32): three `pmove`s —
  `%sp@,%tc`, `%sp@,%tt0`, `%sp@,%tt1` — shutting down the
  030's MMU including both transparent-translation regs;
  tail is `bras` over a dead `.word 0` into `reset; jmp a0@`
  (the 68020 40.1 used `nop; jmp a0@`; the 68020 43.2 does
  movec+reset via a different encoding).
- Region +8 vs 68020-40.1: fnoffs addlib +0x6e, closelib
  +0x80, adddev +0x92, addres +0xa4, addtask +0xb6, addint
  +0xc8, getmsg +0xde, setint +0x112, beginio +0x130,
  addconfigdev +0x152; patch_sysbase code+0x3ca, patch_lib
  code+0x464; InstallExcVecs +0x172, super_excvec +0x194,
  handlers +0x1c2, fsavefix +0x26a.  Table C and data-hunk
  offsets identical to 68020-40.1 (same string lengths).
- GetMsg is the 40.1 variant (no early empty check; keeps
  the `nop` before rts and the single-element quirk).
- Reconstructed by adapting the verified 40.1 sources:
  `source/68030.c` (gate bits only), `68030_patch.s`
  (pmove×3 + reset tail), `68030_lib.s` (name strings,
  shifted table-B fnoffs), `Makefile` (-m68030).
- Built with m68k-amigaos-gcc -m68030 -m68881 -O2 -nostdlib.
- Oracle (machine68k M68030, `work/oracle.py` — jump-table
  LVO model + supervisor frame emulation + ROM reset landing
  on a Done trap):
  - Normal init (attn 0x04 / 0x14, mmu 0/1): identical call
    sequence incl. all 11 table-B SetFunctions (expansion
    -30 included), identical header (ver 40 rev 1) and
    0x70-byte priv block; FPU path runs
    Supervisor(super_excvec) + CacheClearU identically.
  - Fail paths identical: expansion→0x3f02800a,
    utility→0x3f02800c, input.device→0x3f028021,
    mmu→0x3f02803e + UnpatchTable-A; CPU gate (0x00/040)
    silent-fails identically.
  - Post-init vectors identical: dead-vector alerts,
    LibOpen/Close/Expunge, FPUControl byte RMW, GetMsg
    (empty/1-elt/2-elt), BeginIO cmd gating, all
    CacheClearU trampolines, AddConfigDev alert, ColdReboot
    supervisor path runs pmove×3 + reset + ROM jump.
  - exec -36 slot left unpatched (confirmed — 43.2 feature).
- Files: source/{68030.c, 68030_patch.s, 68030_lib.s,
  Makefile}; builds `68030.library`.

- Phase: byte-verbatim rebuild (2026-10-15).  Added
  `source/68030_h0.s` -- the whole CODE hunk as labelled gas
  mnemonics (memory-indirect PC operands, the abs-indexed
  `movel a2,@(0,d0:w)` and the mem2mem movem kept as verbatim
  .short runs, matching 680x0-sibling convention) plus the DATA
  hunk verbatim (InitTable, 37-slot functab, strings, patch
  tables A/B/C).  `source/Makefile`: `make` builds h0.s with
  `m68k-amigaos-gcc -m68030 -m68881 -nostdlib -nostartfiles
  -Wl,-s`, then `fixup.py` and cmp -> BYTE-IDENTICAL, md5
  0f616819707961d57780a65b11d1815a.  `make cmodel` keeps the C
  reconstruction (68030.c + 68030_lib.s + 68030_patch.s).
- GNU ld emits each hunk's RELOC32 groups sorted ascending; the
  shipped binary keeps the multi-object link order (code hunk
  [0x424,0x27e,0x278,0x6] / [0x444,0x284,...] ; data hunk
  [0x1c4..0x1f4,0x174,0x180,0xc..0xa0] / [0x4]).
  `source/fixup.py` verifies identical (hunk,offset-set) groups
  and splices the original RELOC32 tails in place.
- Oracle re-run orig vs rebuild: identical logs across init
  (attn 0x04/0x14, mmu 0/1), patched vectors (GetMsg
  0/1/2-element ports incl. the single-element tail quirk,
  BeginIO cmd 9 vs 5, all CacheClearU trampolines, AddConfigDev
  alert, ColdReboot supervisor path -> pmove tc/tt0/tt1 +
  reset + ROM-vector jump) and fail cases nofpu/mmu0/noexp/
  noutil/nommu/noinput/nocpu/cpu30 -> RUNTIME-IDENTICAL.
- Note: the earlier log's claim that 68020-40.1 used
  `nop; jmp a0@` was wrong -- the 68020 sibling has the same
  `bras` over a dead `.word 0` into `reset; jmp a0@`; the real
  030 deltas at that site are only the two extra pmoves
  (tt0/tt1) and the widened `bnes` skip.
