# Findings & defects

- initfn gates on AttnFlags; returns 0 under the stub harness on
  both builds (same as the FPU sibling's gate matrix).
- The 040-specific encodings (fmovem, fs*/fd* aliases) required
  extending the line-F oracle: fmovem -(a7)/(a7)+ mask semantics
  plus ops 0x40-0x45,0x58-0x5e,0x60-0x6c and monadic
  fetoxm1/ftanh/fatan/fsin/ftan/fetox/ftwotox/ftentox.
- Machine68k has no FPU — all FP results flow through the
  software trap; identical on orig and rebuild.
