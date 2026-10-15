# LibOpen (LVO -6)

Shipped: SAS/C per-open runtime -- allocates a private copy of
the 30-byte jump-table prefix + 88-byte library base, applies
the fixup table (empty here), calls the per-open init which
stores SysBase in the data area and does
`OpenLibrary("intuition.library", 0)` into data+0x14; bumps
lib_OpenCnt; CacheClearU on exec >= 36; returns the private
copy.  Failure frees the copy and returns 0.

Reconstruction: shared-base equivalent -- count++, clear
LIBF_DELEXP, `OpenLibrary("intuition.library", 0)` into the
base's intuition field (unchecked, like the original).
