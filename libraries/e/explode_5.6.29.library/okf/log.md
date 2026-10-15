# log

- Disassembled 1644-byte single-hunk binary; identified "Executable
  Explode Wedge V5.6.29 (16-Jul-91)" — a dos LoadSeg (-150) vector
  wedge that inflates packed executables in place at load time.
- Decoded: AUTOINIT header (LONG functab, 24-bit-offset datatab
  form), 6 vectors, wedge install/remove logic including foreign
  moveq;bra wedge stealing, the -30 jsr+inline-data API, and the
  backward bit-reader LZ decoder with ring buffer staged in the last
  hunk, coroutine refill, and interleaved relocation fixups.
- Reconstruction: decoder/stub/trampoline/hunkwalk/tables transcribed
  as labeled mnemonics (register-coroutine; not C-verifiable); lifecycle
  + wedge install in C. Asm span verifies byte-identical (0/0x3F6
  diffs); C codegen reviewed instruction-for-instruction (long stores,
  indexed reads, alert/setfunc LVOs all match semantics).
- Three label-placement fixes caught by byte diff: reloc-item loop
  head, mid-copy re-entry after refill (a1 must persist), match-copy
  loop must re-check the ring-top wrap each byte.
