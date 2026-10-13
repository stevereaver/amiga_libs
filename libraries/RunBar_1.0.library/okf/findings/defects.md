# RunBar 1.0 — shipped quirks and defects

1. **RB_Remove under lock returns 1** — the `flag==1` early
   exit jumps into the epilogue with d0 still holding the
   `moveq #1` constant used for the compare.  Callers see 1
   (not 0) for a no-op'd remove.  Replicated literally.

2. **Slot array is 16, loops bound at 15** — every scan uses
   `d7 == 15 -> exit` before processing, so `ent[15]` is
   allocated (320B table inside 0x194 base) but unreachable.

3. **RB_Reset leaks ports** — clears the 15 keys + flag but
   never deletes `slot.port`; the orphaned MsgPorts keep their
   signal bits and memory until process exit.

4. **RB_Send swallows all failures** — not-found, port-alloc
   failure and msg-alloc failure all return 0, same as success;
   the GetMsg reply is stored into a dead stack slot.

5. **OOB template read at init** — LibInit copies 128 bytes
   starting at the 36-byte DATA hunk: bytes 36..127 come from
   whatever follows in memory (rebuild uses a padded 128-byte
   template instead — deterministic zeros; the live fields at
   +20/+24 are inside the real 36B in both cases).

6. **Dead hook calls** — LibInit `bsr`s a `moveq#0;rts` stub
   whose result gates a dead fail path (`cmpiw #0x200d` is
   another dead instruction); LibExpunge `bsr`s a bare `rts`.
   Both replicated as asm stubs to keep the call pattern.

7. **Dead compare in the copy loop** — `cmpiw #0x1cd9,d0`
   (d0==8) immediately before `subql/bcc` discards its flags.
   SAS/C peephole artifact.

8. **Reply never waited properly on teardown** — like -48, -60
   dead-stores the reply; if no handler services the slot port
   the PutMsg'd shutdown requests just get drained by the lib
   itself via ReplyMsg loops (harmless under the emulation).
