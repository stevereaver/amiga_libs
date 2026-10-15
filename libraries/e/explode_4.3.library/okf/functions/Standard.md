# Standard vectors

- **LibOpen (-6)**: `addq.l #1,42(a6)` - private counter at +0x2a;
  the real `lib_OpenCnt` is left at the init value 1.  Returns base.
- **LibClose (-12)**, **LibExpunge (-18)**, **LibNull (-24)**:
  all alias the same `moveq #0,d0; rts` stub.  The library can never
  be expunged - required since its LoadSeg hook points into its code
  forever.
