# Work log

- Parsed hunk: single CODE hunk; entry stubs at +0/+6
- Mapped RomTag (AUTOINIT ver 1), InitTable (dataSize 0x30),
  absolute functab (10 vectors + -1), InitStruct stream
- Found lh.library dependency: LibInit OpenLibrary's it, Expunge
  CloseLibrary's it; base holds seglist/SysBase/lhbase
- Decoded codec LVOs as lh delegation: lazy lh -30 control block
  + 0x9000 scratch buffer, lh -42 pack, lh -48 unpack, shared
  free at both -42/-60 slots
- Spotted quirks: "LBLB" idstring typo, cmpa.w 16-bit NULL
  checks, CCR-Z error test, DELEXP-set-first Expunge,
  Close-before-decrement guard
- C reconstruction: framework + adapter in xpkLHLB.c, resident
  module + descriptors in xpkLHLB_lib.s; builds clean
- Verified all jsr offsets in compiled code
