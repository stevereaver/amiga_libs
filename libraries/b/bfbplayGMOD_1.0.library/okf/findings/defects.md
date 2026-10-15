# Defects & inconsistencies — bfbplayGMOD.library V1.0

1. **In-place string mutation.** ensure_resources patches the
   "ciaa.resource" name string's byte 3 to 'b' permanently to open
   "ciab.resource" — the code hunk is self-modifying (idempotent on
   later calls, but breaks if the string ever lives in ROM/write-
   protected memory).
2. **modbuf at unaligned +2.** The session struct puts modbuf at
   offset 2 and modlen at +10 — all long accesses are odd-word
   misaligned; a 68000 would trap, 68020+ required in practice.
3. **Seek-return size trick is fragile.** sess+10 (file size) takes
   the return value of the Seek(0,BEGIN) rewind — the *old* file
   position.  Correct only because the preceding Seek(0,END) left it
   at EOF; a caller-supplied handle that was already at EOF gets the
   same value, but any mid-positioned handle records a wrong size.
   (In practice the END seek lands at EOF so it works.)
4. **Unused fields carried over.** The session keeps PSID-family
   fields (+6 buf2, +14 len2, +30 name, +34 namelen, +38 buf3,
   +42 len3) that nothing ever initializes; EndModule frees +2/+10
   and +38/+42 unconditionally-on-nonzero, so a caller-supplied
   session with garbage there could free wild pointers (only the
   MEMF_CLEAR alloc path makes it safe).
5. **Stubs return -1.** Three consecutive vectors (-54,-60,-66) are
   pushall/-1/popall stubs — ContModule and friends were never
   implemented for GMOD (no pause/continue path; the tick flag byte
   only gates the softint).
6. **GetInfo is empty** — always returns 0 (PSID lazily built a
   4-long info record; GMOD has none).
7. **Global session, single instance.** cur_sess is a code-hunk
   global — only one module can play; InitModule blindly overwrites
   it, leaking the previous session's liveness for the tick path.
8. **Expunge doesn't stop playback.** If expunged while a module
   runs, the CIA timer still fires -> softint -> cur_sess dangling
   (the lib memory is freed; the dispatcher reads a stale global).
9. **type byte = 7 hardcoded**, fmtname "GMOD"; the +20 songs-1 and
   +24 cursong fields are WORDs — modules with >32767 songs would
   wrap.
10. **SetSubsong stores 0-based** (unlike PSID's 1-based +1 store)
    and clamps by keeping the old value when n > songsm1 — negative n
    returns current without change.
