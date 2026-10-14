# prometheus 2.5.library — work log

- Hunk parse: CODE 0x266 L (2456 B) + DATA 0x13 L (76 B), 2728 B.
- RomTag@h0+4: COLDSTART (flags 0), ver 2, rt_Init -> h0+0x4ce.
  Init calls exec MakeLibrary with the h1 functab (18 absolute longs).
- [subagent work] Full disasm + verbatim asm transcription to
  prometheus.s (single source, both hunks via .text/.data + hunks.x
  ordering + fixup.py for reloc group order).
- Build: byte-identical to original.
- [integration] Oracle written: fake exec (real MakeLibrary/MinList/
  pools), expansion FindConfigDev -> fake cdev, utility tag fns,
  Prometheus.card DMA stubs; board cfg space mapped into RAM so the
  init scan probes real BARs. Original vs rebuild traces identical
  end-to-end incl. WriteAddresses BAR programming and teardown.
- md5: see source dir build (`cmp` clean).
