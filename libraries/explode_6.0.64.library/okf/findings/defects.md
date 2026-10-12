# Defects / quirks reproduced

1. `-18 Expunge` and `-24` vectors both point at a `moveq #0; rts`
   stub — the library cannot be expunged through the normal vector;
   teardown only happens via Close reaching OpenCnt==0 with the
   private flag byte armed by -36.
2. Expunge only restores the NewLoadSeg vector **operand** (writes
   the saved vector into slot+2). It never restores the whole slot
   contents — assumes the `4ef9 jmp` opcode is still there.
3. The "ed explode.libra" variant signature is a 16-byte PREFIX
   match — no terminator or trailing bytes checked; anything
   starting "ed explode.libra" at hunk+40 triggers a decrunch.
4. On an unpatchable LoadSeg slot the recoverable Alert 0x00028007
   path returns the library successfully installed but completely
   inert (no wedge) — a silent no-op install.
5. CacheClearU runs only when exec lib_Version >= 37 — on 1.3 and
   older the self-modified stubs + decrunched code rely on the
   68000/010 not caching instructions.
6. lib_Revision is 0 in the datatab even though the id string says
   "V6.0.64" (the .64 is the build number, not the rev field).
7. NewLoadSeg hook only exists for exec>=37; on 1.3 the lib misses
   loads that bypass LoadSeg (NewLoadSeg didn't exist there anyway).
8. tab2 has only 108 bytes — 10-byte records indexed by a header
   nibble*10 means records past index ~9 read past the table end
   (the packer presumably never emits those).
