# Vestigial RomTag + data-hunk InitTable

rt_EndSkip = +0x1e (covers only the header) and rt_Init points back
at the RomTag itself - InitResident would malfunction on this
resident.  The library is meant to be loaded by xpkmaster, which
finds the real InitTable at DATA+4 (dataSize 0x13a, functab,
initfunc).  The CODE hunk's id string is merely "Version 1.0" while
the real `$VER:` lives in the DATA hunk.
