# dospath.library 1.0 — quirks & defects

1. **hunk1 short body**: header table allocates 12B for the globals hunk
   but the DATA record carries only one long. Loaders zero-fill the rest,
   so this is benign.

2. **rt_EndSkip -> h0+0x54** (the functab) instead of past the resident
   code — EndSkip only needs to be >= romtag end, so this is legal but
   unusual.

3. **Signed opencnt test in Expunge/Close**: `cmpiw #0; blss` means the
   immediate-expunge path triggers when opencnt < 0, and opencnt == 0
   takes the DELEXP deferral path. With the clone-per-open scheme the
   master lib's +32 counter is incremented by Open on the *caller's* base
   (a6) and decremented by Close via h1+0; a fresh master starts at 0 so a
   first Expunge never frees the library (sets DELEXP which is then
   cleared by the next Open's `bclr`).

4. **Clone global confusion (by design?)**: h1 globals are shared between
   master and all clones, so every clone's `a4`-based globals point at the
   master's libbase/seglist/sysbase — Close and Expunge always operate on
   the master.

5. **Encoding trivia**: the original assembler used the generic
   `SUB.L #imm,Dn` encoding (`90bc`) for the tag compare where gas emits
   `SUBI` (`0480`); reproduced via raw `.short 0x90bc`.

6. **a4 wrap-around addressing**: `lea h1+0x7ffe,a4` plus negative
   displacements is a hand-rolled small-data model; the lea sites carry
   all 12 h0->h1 relocations.

7. Dead code: ret0 stub at h0+0, a row of ret0/ret1/nop/rts stubs at
   0x984-0x99f (compiler padding), and nop padding between functions.
