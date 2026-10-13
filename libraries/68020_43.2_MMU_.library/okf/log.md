# 68020.library 43.2 (MMU) — RE log

- Started from the completed 40.1 sibling (`68020_40.1_MMU_`).
  Byte-diffed the two hunks: code 1320→1316 B, data 512→516 B,
  ~1046 identical code bytes.
- Init (code+0x4a) byte-identical to 40.1 except
  `lib_Version 40→43`, `lib_Revision 1→2`, and shifted
  absolute operands: patch_sysbase store `0x3c2→0x3e4`,
  patch_lib `0x45c` (same), table A `0x174→0x178`,
  table B `0x180→0x184`.
- Decoded the changed patch region:
  - super_coldreboot (region+0x32): after `pmove %sp@,%tc`
    added `moveq #0,d0; movec d0,cacr; movec d0,vbr`; tail
    replaced with `bras fwd / reset / jmp a0@ / bras back`.
  - pf_getmsg (region+0xe0): early `lh_TailPred == &lh_Head`
    empty check returning 0 before INTENA is touched; the
    `head->ln_Succ == 0 ⇒ return 0` quirk remains.
  - New pf_lvo36 (region+0x11c): tail-call trampoline with a
    vestigial `tstw $dff01e` (INTREQR).  Exec slot -36 is not
    in the NDK LVO list — internal exec dispatch slot.
  - pf_addconfigdev + its slot removed; table B loses the
    `liboff 56,-30` record (expansion still opened, unused).
  - 68881 handlers at region+0x1ba.. and pf_fsavefix at
    +0x262 byte-identical to 40.1 (bra.w/bras.s/bnes mix).
- Corrected an earlier mislabel: table C targets VBR+0xc0..0xd8
  = **vectors 48-54, the 68881 FPU exception vectors**
  (BSUN/Inexact/DivZero/Underflow/OperandError/Overflow/SNaN),
  not TRAP #0-6.  Flag bits in lib+34 map bit0→48, bit1→49,
  bit2→50, bit3→51, bit4→53, bit5→54, bit6→52.
- Reconstructed: `source/68020.c` (init/lifecycle/FPUControl,
  only version/rev changed vs 40.1), `68020_patch.s`
  (coldreboot/getmsg/lvo36 deltas, addconfigdev removed),
  `68020_lib.s` (43.2 idstr, new table B, same table C).
- Built with m68k-amigaos-gcc -m68020 -m68851 -m68881 -O2
  -nostdlib → 4032-byte HUNK library (code 1424 B vs shipped
  1316 — GCC layout differs; region fnoffs reproduced exactly).
- Oracle (machine68k M68020, `work/oracle.py` —
  jump-table LVO model, Supervisor frame emulation, ROM reset
  landing on a Done trap):
  - Normal init (attn 0x02 + 0x12, mmu types 0/1): identical
    call sequence (openlibs, Forbid/FindName/Permit, table-A
    SetFunction, mmu open/GetMMUType, supervisor excvec
    install + CacheClearU on the FPU path, ten table-B
    SetFunctions incl. -36, Enable), identical lib header
    (ver 43 rev 2, idstring ptr) and 0x70-byte priv block.
  - Fail paths identical: expansion→alert 0x3f02800a,
    utility→0x3f02800c, input.device→0x3f028021,
    mmu→0x3f02803e + UnpatchTable-A restore of -726, all
    ending close-opened-libs + FreeMem(lib-NegSize,
    NegSize+PosSize) + return 0; CPU-gate fails
    (attn 0x00 / 68030 flag) identical.
  - Post-init vectors identical: dead-vector alert, LibOpen/
    Close/Expunge stubs, FPUControl flag byte RMW.
  - pf_getmsg: n=0 → 0 (new early-out path), n=1 → 0
    (single-element quirk), n=2 → head node — identical.
  - pf_lvo36 tail-calls its saved old vector identically;
    pf_beginio cmd 9 vs 5 CacheClearU gating identical.
  - pf_coldreboot: Disable→CacheControl→Supervisor path runs
    super_coldreboot to the ROM reset jump identically,
    then Alert(0x3f000002)/Enable on return.
  - Patch region bytes: byte-identical to shipped modulo the
    relocated patch_lib operand in InstallExcVecs.
  - Data hunk: byte-identical modulo relocation addends;
    identical reloc offset set.
