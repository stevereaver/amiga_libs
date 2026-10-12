# xpkHFMN 1.28 — log

## Analysis

- 1928B AUTOINIT lib, single code hunk 0x6e4. `moveq #-1; rts` entry
  stub + vestigial alloc-size words at code+4 (1.4 uses `moveq #0`).
- RomTag: name→0x22, idstr→0x32, init→0x8c. LONG-offset functab
  (10 entries + ffffffff), datatab version 1 rev 28.
- IRA misdecoded 020 instructions (BFINS extension words as DC.W);
  corrected via objdump/byte inspection.
- Codec = same dynamic-Huffman architecture as the reconstructed
  xpkHFMN 1.4: identical workmem layout, heap/merge order, child/
  parent/codes/len tables, preorder tree serialization, LSB-first
  leaf symbols, MSB-first data codes. Pack emit uses real BFINS.
- Unpack is completely different: LAB_0039 generates m68k decoder
  code into workmem and jsr's it (see structures/codegen.md).
- -42/-48/-60 are rts stubs (per-call alloc/free, no Sub[] slots).
- Expunge inlines the unlink; no OpenCnt check.
- Descriptor is the older 4-word-version + long-pointer format;
  xi_DefMode=0, single "normal" mode (28B + inline name).

## Reconstruction

- `source/xpkhfmn.c` — codec + lifecycle + LAB_0039 codegen in C.
  HOST_TEST build includes a generated-code interpreter (sim_decode)
  for host verification.
- `source/xpkhfmn_lib.s` — stub/RomTag/strings/LONG functab/datatab/
  initfn/rts stubs/reserved stub/dead example bytes/descriptor/mode.
- Long functab needs no generation pass.

## Verification

- Host round-trips: hello/aaaa/mixed/skewed/readme/fib/deepskew/
  single/two_skew — all byte-exact. rnd4k → -17 (faithful: incompressible
  exceeds OutBufLen budget).
- Pack streams byte-identical to verified xpkHFMN 1.4 C output on all
  five shared inputs.
- Streams decode correctly through 1.4's independent Python decoder.
- My generated-code decoder accepts 1.4-produced streams (format
  cross-check).
- Generated code verified instruction-by-instruction vs disassembly
  (template 28B, node `d080 6400 0000`+patch, leaf
  `72ss 14c1 72dd 51cf dd 4e75`, dbf target = helper top).
- fib corpus produces maxdepth=19 codes — exercises the 16-bit refill
  path.
- m68k codegen checked: alloc/free sizes+flags, AttnFlags bit gates
  (btst on low byte = AttnFlags bits 1/2), exec ver>=36 + CacheClearU,
  jsr (a4) sequence, inline expunge unlink.
- m68k binary: header region byte-identical layout (RomTag, strings,
  datatab, init at 0x8c on 4-byte boundary, functab entries resolve).
