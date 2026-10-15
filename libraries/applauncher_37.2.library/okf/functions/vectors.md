---
file: vectors
---
# Vectors

21 LVOs (-6 .. -126). functab assembled into the DATA hunk
(SAS/C a4-relative model); entries resolved through the a4 anchor
`lea $7ffe,a4` + reloc. User vectors exercise exec -684 (AllocMem),
-672, -360, -522, -294/-132 (exec semaphore ops), -390/-138,
-690 (FreeMem-family), -252 CloseLibrary, -414 RemLibrary,
-210 FreeMem — consistent with a launcher that spawns/registers
applications.

initfn: a2=0 in the MakeLibrary args — lib state initialized
inline during bootstrap.
