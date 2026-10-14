# Work / verification log

## Static analysis

1. Parsed hunk header: magic `0x3f3`, one CODE hunk `0x3e9`,
   0x277 longs, body at file offset **0x20** (earlier offset guesses
   produced a misaligned disassembly; re-extraction verified the
   `7000 4e75` entry and `4afc` RomTag at +4).
2. Full disassembly with `m68k-amigaos-objdump -D -b binary -m m68k`
   saved to `work/duke_dis.txt` (extracted hunk in
   `work/duke_code.bin`).
3. Byte-compared DUKE vs NUKE 1.8 code: pack core and decode loop
   are byte-identical; the differences are the wrapper (delta
   loops), workspace size 0x3758c vs 0x3005c, and DUKE
   strings/descriptor.

## Reconstruction

- Ported the proven NUKE 1.8 C codec verbatim; added the delta
  preprocessor (PackChunk common path) and 8-wide cumulative
  post-pass (UnpackChunk tail).
- Same skeleton as NUKE: asm RomTag/InitTable/datatab/lifecycle +
  two-pass word-offset functab (`genfunctab.py`, `functab_stub.s`,
  `tail.o` linked last for `_TagEnd`).
- Built with `/opt/amiga/bin/m68k-amigaos-gcc -O2 -m68000
  -nostdlib -nostartfiles` → `source/xpkDUKE.library`
  (code hunk 0x45b longs; larger than the original — GCC codegen
  differs; functional equivalence is the criterion).

### Bug found & fixed during verification

- First oracle diff: `lit16` — original returned rc=0 with
  outlen=16=inlen; rebuild returned -17. Cause: the original's
  success gate is `cmpl a5@(4),d0; blss` (`0x6304` = **BLS**,
  lower-or-same), so `outlen <= inlen` counts as success. The
  transcription initially used `<`. Fixed in `xpkDUKE.c`; NUKE's
  original has the identical sequence (latent in its C port — its
  test corpus never produces outlen==inlen).

## Oracle runs (machine68k)

- `work/oracle.py` — loads the hunk, emulates MakeLibrary/InitStruct,
  stubs AllocMem/FreeMem/Remove, exercises all 10 vectors.
- `streamsO/` (original) vs `streamsR/` (rebuild): all 20 corpus
  streams byte-identical; rc/outlen/unpack-match lines identical.
  Lifecycle trace identical (deferred expunge → Remove +
  FreeMem(132)); PackerInfo descriptor identical; PackFree →
  `freemem(…,196700)` + stale sub pointer identical; tiny-outbuf →
  -17 with outlen 0xffffffff identical; realloc-after-PackFree
  reuses freed block on both.
- Randomized differential (301 cases in `/tmp/res_{a,b}.pkl`,
  driver `/tmp/difftest.py`): kinds = random byte/uniform-4/ab/
  mod-17/short-periodic/zeros across sizes 0..30000 — **0
  mismatches**; all successful packs round-trip on both sides.
- Two n=30000 random-'ab' inputs initially "mismatched" with stale
  garbage: the pack needs ~215M cycles (huge candidate chains on
  ±1 deltas) and the 200M-cycle `execute` budget silently returned
  mid-run d0. Budget raised to 3e9 in oracle.py; both sides then
  produce identical 7044/7048-byte streams. Not an infinite loop —
  verified by chunked execution reaching the ENDTRAP.

## Known tool limitations

- machine68k traps appear process-global: two Machine objects in
  one process corrupt each other's trap dispatch. Differential
  tests run the two binaries in separate processes.
