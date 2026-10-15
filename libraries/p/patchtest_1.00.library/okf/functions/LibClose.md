# LibClose (LVO -12)

Shipped: for a private copy (base+0x32 != self), calls the
per-open cleanup (CloseLibrary if data+0x14 non-NULL) and frees
the copy; decrements open count; on zero with LIBF_DELEXP set,
branches into LibExpunge and returns its seglist.

Reconstruction: CloseLibrary when opened, count--,
DELEXP -> LibExpunge -- identical observable behavior.
