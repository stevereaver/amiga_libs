# lh.library dependency and delegation

xpkLHLB contains no compression code of its own:

- `LibInit` calls `OpenLibrary("lh.library",1)`; failure makes it
  FreeMem the freshly allocated library base and return NULL, so
  the module refuses to exist without lh.
- The codec LVOs delegate to lh vectors -30/-36/-42/-48 with a
  4-longword control block allocated by lh itself.
- `LibExpunge` calls `CloseLibrary(lhbase)` before Remove/FreeMem.

Consequences:

1. The XPK descriptor claims `xi_Flags=9` (pack + unpack chunk)
   and advertises speeds of 140/1043 -- inherited marketing, not
   measured behaviour; real performance is lh's.
2. lh 1.8 in this collection has a 7-vector functab, i.e. LVOs
   -6..-42 only.  xpkLHLB's unpack path calls lh vector **-48**,
   which is outside lh 1.8's defined table.  Either LHLB targets
   a different (fuller) lh release, or its unpack path has never
   been exercised against 1.8.
3. `xsp_OutLen` on pack is the lh byte count copied from scratch;
   on unpack it is lh's return value directly.
