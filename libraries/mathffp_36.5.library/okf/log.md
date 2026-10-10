# mathffp_36.5 work log

- Parsed 0x3f3 overlay header: 4 hunks (code 0x134 lw, banner
  0x11 lw, two empty), packed RomTag, InitTable @0x48,
  dataSize 0x22, word-offset functab @0xf8.
- Functab format confirmed: leading -1 = word-offset table,
  signed offsets from table base; all 16 vectors decoded and
  matched against ndk/lib/fd/mathffp_lib.fd (bias 30, args
  d0/d1 as documented).
- InitStruct datatab decoded via exec/initializers.h
  (0xa0=byte, 0x90=word, 0x80=long commands) → NT_LIBRARY,
  name, flags 6, ver 36 rev 5, idstring w/ \r\n.
- Full disassembly of all 12 functions; SPCmp/SPTst use exec
  GetCC (-528) to snapshot real compare flags.
- Built a bit-exact Python oracle of every function
  (work/model.py); iterated until 80k+ normalized-case
  float sanity passed, then fixed model bugs found by the
  harness: (a) mul underflow test is V/C flags of subq.b
  (resb==0x80/0x00), (b) divu overflow leaves destination
  unchanged, (c) cmp.w/bmi is SIGNED, (d) the roxr carry path
  checks addq's own V/C flags.
- Reconstructed in C (source/mathffp.c) + asm skeleton
  (RomTag/strings/InitTable/datatab/functab/lifecycle/banner).
- Host harness: C vs Python oracle, 1,649,955 invocations,
  0 mismatches.
- m68k build produces a working .library (functab entries
  verified to land on each function; datatab byte-identical to
  original).
