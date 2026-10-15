# Hardware dependencies

Drives a parallel-port MP3 decoder (MAS Player Pro): claims
misc.resource units 2 (MR_PARALLELBITS) and 3 (MR_PARALLELALLOC),
writes CIAA_PRB strobes and CIAB_PRA data.  Absolute CIA addresses
are stored in the DATA hunk ($bfe001/$bfd000), not the bss base.
