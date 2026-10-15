# Inconsistencies / defects (shipped)

1. **Session LONGs are unaligned** (+2,+10,+26): address-error on a
   plain 68000/68010 — the library only works on 68020+.
2. **maxvol never initialized.** The 80B session is MEMF_PUBLIC (no
   CLEAR) and +20 is never written; SetVolume clamps against heap
   garbage — nondeterministic volume ceiling.
3. **Session store-back encodes `a1@(4)`.** After AllocMem for the
   session the code does `movel d0,a1@(4)` with a1 call-clobbered —
   the ti_Data write-back goes wherever AllocMem left a1 (latent
   stray write); reconstruction stores to the tag item as intended.
4. **Early-error unwind uses uninitialized `sess`.** Missing
   0x80000007 tag or failed session AllocMem reaches the cleanup
   path with the register un-set — wild FreeMem possible.
5. **medplayer double-close in Expunge:** calls medplayer's -36
   vector directly and *then* exec CloseLibrary — decrements its
   open count twice (can expunge it under other users).
6. **InitModule returns -4/-8/-17 without cleanup** on some paths
   (medplayer missing, tag7 alloc fail) but full cleanup on others —
   inconsistent unwind (matches shipped flow).
7. **Dead 31-long trailer** appended after the code hunk (file
   0x580..0x5fb) — never loaded; looks like a build artifact
   (mixed constant table). Not reproduced inside the hunk.
8. **Unused "MED / OctaMED" string** in the binary (reproduced).
9. **GetDesc returns a bare pointer** to a multi-line static string.
