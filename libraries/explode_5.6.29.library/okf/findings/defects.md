# Findings / defects / quirks — explode 5.6.29

1. **-18 expunge vector is dead** (`moveq #0;d0;rts`). The only way to
   expunge is `Open`=0 + `Close` with the +34-bit3 flag armed by -36.
   An OS-level `RemLibrary`/vector expunge is a silent no-op and leaves
   the LoadSeg wedge installed pointing at freed memory if the lib was
   forcibly removed.
2. **-30 decrements `lib_OpenCnt` unconditionally.** Every Explode
   call consumes one open; a caller that never opened the library
   drives the count negative/into expunge. No pairing is enforced.
3. **Wedge identity check is shallow.** The install recognises only
   `4EF9 jmp abs` and the `70 xx / 60 xx` moveq;bra stub of its own
   family. Any other prior wedge form => recoverable Alert and the
   library loads **without installing** — a silent no-hook state.
4. **Foreign-wedge stealing.** When the slot already holds a
   moveq;bra wedge it copies that wedge's moveq immediate and calls
   the *real* target directly — the previous wedge is bypassed, not
   chained. Load order determines whose hook actually runs.
5. **Signature is weak**: `48E7FFFF` at hunk+4 plus the literal
   `explode.library` at hunk+40. No format/version field is checked;
   a false positive inflates (and frees hunks of) a non-packed exe.
6. **No bounds checking in the decoder**: bit reader, ring pointers
   and the reloc applier trust the stream completely; a corrupt
   stream walks memory and the tail `FreeMem`s hunk headers by their
   own size fields.
7. **Expunge refusal leaves state odd**: if the slot was re-patched,
   expunge returns 0 but Close already decremented OpenCnt — the
   library stays loaded with count 0 and the foreign wedge in place.
8. **Stub patching is not atomic**: 6 bytes are overwritten across two
   stores under `Forbid` only — a task with the old vector already in
   a register is fine, but an interrupt-time LoadSeg could see a
   half-patched `jmp` operand (Forbid doesn't stop interrupts).
9. **Alert codes hardwired**: `0x80038007` deadend if dos.library
   fails; `0x00028007` recoverable for an unpatchable slot.
