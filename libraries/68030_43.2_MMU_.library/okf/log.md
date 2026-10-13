# 68030.library 43.2 (MMU) — RE log

- Started from the completed 68020 43.2 sibling
  (`68020_43.2_MMU_`) — same release date, expected to be a
  cross-CPU variant.  Binary: 2208 B, CODE hunk 1332 B,
  DATA hunk 516 B (data layout identical to 020_43.2).
- IRA crashed (segfault) repeatedly on the raw binary and on
  extracted hunks; fell back to objdump + raw byte diffs
  against the two completed siblings.
- Code-diffed against 68020_43.2:
  - Init (code+0x4a) identical shape except the CPU gate:
    `btst #3`→fail (AFF_68040) + `btst #2`→require
    (AFF_68030), vs the 020's `btst #2`-fail/`btst #1`-req.
    NO68881 bit set when AFF_68881 clear — same.
  - super_coldreboot: 030 PMMU variant — unconditional
    `pmove %sp@,%tt0` / `pmove %sp@,%tt1` loading
    `0x00ff8707` (translators off), then the gated
    `pmove %sp@,%tc` (skipped when lib+43 bit1 "no MMU"
    set), then the shared 43.2 `movec cacr/vbr` + `reset` +
    ROM jump tail.  16 B longer than the 020 routine ⇒ all
    later region offsets shifted +0x10.
- Data hunk decoded byte-for-byte: identical tables to
  020_43.2 (table A ColdReboot; table B ten vectors incl.
  the exec -36 internal slot; table C seven FPU exception
  vector records), only the lib-name string and the
  region-relative fnoffs (+0x10) differ.
- Reconstructed by adapting the 68020_43.2 sources:
  `68030.c` (030 gate + version), `68030_lib.s` (name/idstr,
  fnoffs +0x10), `68030_patch.s` (030 PMMU prelude).
- Build fix: `pmove %sp@,%tt0/%tt1/%tc` need `-m68030`
  (the 020 Makefile's `-m68020 -m68851` rejects the 030
  TT-register operands); switched CFLAGS+ASFLAGS to
  `-m68030 -m68881`.
- Structural verification:
  - Patch region byte-identical to shipped modulo the one
    relocated `patch_lib` operand in InstallExcVecs.
  - Data hunk byte-identical modulo relocation addends;
    identical reloc offset set (48 relocs).
- Oracle (machine68k M68030, `work/oracle.py` adapted from
  the 020_43.2 harness — jump-table LVO model, Supervisor
  frame emulation, ROM reset landing on a Done trap):
  - Normal init (attn 0x04 no-FPU, 0x14 68881-present;
    mmu types 0/1): identical call sequence — openlibs,
    Forbid/FindName(input.device)/Permit, table-A
    SetFunction(-726), mmu open + GetMMUType, supervisor
    exception-vector install + CacheClearU on the FPU path,
    ten table-B SetFunctions incl. -36, Enable; identical
    lib header (ver 43 rev 2) and 0x70-byte priv block.
  - CPU gate: attn 0x00, bare-68020 (0x02), and
    030+040-flags (0x0c) all reject identically (free +
    return 0, no alert).
  - Fail paths identical: expansion→0x3f02800a,
    utility→0x3f02800c, input.device→0x3f028021,
    mmu→0x3f02803e + UnpatchTable-A restore of -726; each
    ends close-opened-libs + FreeMem(lib-NegSize,
    NegSize+PosSize) + return 0.
  - Post-init vectors identical: dead-vector alert,
    LibOpen/Close/Expunge stubs, FPUControl RMW.
  - pf_getmsg: n=0 → 0 (early-out), n=1 → 0
    (single-element quirk), n=2 → head node — identical.
  - pf_lvo36 tail-call, pf_beginio cmd gating, all
    CacheClearU trampolines identical.
  - pf_coldreboot: Disable→CacheControl→Supervisor runs
    super_coldreboot identically to the ROM reset jump
    (030 PMMU pmoves byte-verified since the emulator does
    not model PMMU regs), then Alert(0x3f000002)/Enable.
  - FPU path: super_excvec writes handlers to VBR+0xc0..0xd8
    and absolute low memory in identical order
    (region-relative offsets match); saved-vector slots
    left at lib+0x50..0x68 identically.
- Result: all observable behavior identical modulo relocated
  code addresses; reconstruction verified.
