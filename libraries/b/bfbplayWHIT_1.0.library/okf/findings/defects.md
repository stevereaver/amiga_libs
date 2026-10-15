# bfbplayWHIT.library -- defects / quirks

1. **EndModule leaves `cur_sess` dangling.**  InitModule stores the
   session into the code-hunk global (code+0x204) but EndModule
   never clears it.  After EndModule the softint forwarder reads a
   freed session: `running` byte and `modbuf` come from freed heap,
   so a CIA tick can jsr into freed memory.  (Reconstruction
   preserves this; the tick is also stopped by cia_stop first in
   the normal path.)

2. **Memory-image modules are freed anyway.**  Tag 0x80000003
   installs the caller's buffer at sess+2 without copying;
   EndModule / InitModule error paths FreeMem it with sess+10.
   The caller's buffer is destroyed.

3. **Detector bound is a pointer.**  whit_detect's scan-1 loop
   counter is `modbuf - 28` (a pointer value treated as a byte
   count), so the signature scan is effectively unbounded: on a
   non-Whittaker image it runs forward through RAM until it finds
   `43fa .. 4880c0fc .. 41fa` or hits unmapped memory.

4. **OpenResource retry never happens.**  ensure_resources tests
   only ciaa (+160); if ciab open failed on the first call the
   resource stays NULL while the function reports success on
   subsequent calls (ciaa is set).  cia_start then just cannot
   use ciab timers -- consistent, but asymmetrical.

5. **SetSubsong(-72) has no negative guard.**  n = -1 stores
   0xffff at sess+24 (signed word compare `songsm1 < n` is the
   only check).  GMOD explicitly rejected n < 0; WHIT does not.

6. **Constant at sess+26.**  0x00000074 (116) is stored where
   GMOD kept a format-name pointer; the "David Whittaker" string
   at code+0x76 is dead data, presumably the remnant.

7. **StopModule return value is leftover.**  The -48 path falls
   off through `moveml+rts` without setting d0 (observed return =
   the freed/leftover register), unlike the 0/-1 convention of the
   other vectors.

8. **modbuf offsets unaligned.**  sess+2/+10 (APTR/ULONG) sit at
   odd-ish offsets; the original writes them with plain movel --
   legal on 68000 only because the alloc'd block keeps them
   even-aligned (+2,+10 are even).  MEMF_CLEAR makes the unused
   fields benign.

## Interrupt note

node2's is_Data = 0xbfe001 (CIAA hardware base) is passed to the
tick forwarder as a1 and never used -- vestigial fill, or simply
a recognisable constant.
