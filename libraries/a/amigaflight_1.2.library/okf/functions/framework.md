# Framework vectors

## LibInit (InitTable initfn @ 0x112)

- Stores SysBase (a6) at base+0x24, seglist (a0) at base+0x2c.
- Opens `dos.library` v0 via exec `OpenLibrary` (-552); base at
  base+0x28. Result unchecked (see findings).
- Returns the library base.

## LibOpen (-6, @ 0x138)

- Compares the version argument against 1 (signed).
- If `>= 1`: increments `lib_OpenCnt`, clears `LIBF_DELEXP`,
  returns base. Otherwise falls to `rts`, returning the
  `d0` argument itself (`<= 0`) -- a negative argument would
  return a bogus non-NULL pointer to naive callers.

## LibClose (-12, @ 0x14e)

- Decrements `lib_OpenCnt`; on zero + `LIBF_DELEXP`, tail-calls
  LibExpunge. Returns 0 (or the expunge segment).

## LibExpunge (-18, @ 0x162)

- OpenCnt nonzero -> sets `LIBF_DELEXP`, returns 0.
- Else: `Remove` (-252), `CloseLibrary` (-414) on the dos base,
  `FreeMem` (-210) on `base - negSize` sized `negSize+posSize`.
- Dead instruction at 0x168: loads `a6 <- base+0x24` (SysBase)
  and never uses it before reloading `a6 <- 4.w`.

## LibNull (-24, @ 0x1b4)

Returns 0. The function-table terminator slot (-120) is a
`-1` marker, not a callable vector.
