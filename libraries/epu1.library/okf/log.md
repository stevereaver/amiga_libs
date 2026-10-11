# epu1.library — reconstruction log

- Source: `binary/epu1.library`, 1,564 bytes, 4 hunks
  (code0 0x398, code1 0xa8 requester, data 0x64 IntuiText templates,
  code2 0x34 AutoRequest trampoline).
- IRA dump `work/epu1.asm` mis-parsed RomTag strings/data as code;
  raw bytes + reloc hunks were used for the final map.
- Layout: LONG-address functab, 6 vectors (-6 .. -36), dataSize 0x30.
- Identified as a thin public wrapper over `lh.library`
  (mode 0 = pack via lh -42, mode 1 = unpack via lh -48), with
  intuition AutoRequest RETRY/CANCEL dialogs on OpenLibrary/alloc
  failure.  Sibling of `epu0.library`; lh vector semantics match the
  `xpkLHLB_1.1.library` recon.
- Reconstruction: single code hunk; lifecycle + publics in C using the
  named-register LVO convention; RomTag/InitTable/datatab/strings in
  `epu1_lib.s`; `rt_EndSkip` endmodule.
- Verified: header layout byte-identical to original (name@0x1e,
  idstr@0x2b, init@0x56, datasize 0x30, functab@0x66, datatab@0x82),
  datatab bytes identical, all 6 vectors resolve to linked symbols,
  generated EpuPack/Unpack/Init sequences match original semantics.
