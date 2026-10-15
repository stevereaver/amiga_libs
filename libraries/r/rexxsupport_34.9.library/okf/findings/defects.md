# rexxsupport.library 34.9 — defects & oddities

## 1. FORWARD replies to a stale port pointer (real defect)

`h_FORWARD` (+0x6a6): after `FindPort(arg1)` succeeds
(`movel d0,d3`), the code does

```
Remove(msg);  moveal d2,a0;  PutMsg(d2, msg)
```

`a0` is loaded from **d2 — a register never set in this path**
(left over from the name-scan/arg conversion), not from `d3`
(the found MsgPort).  On a real system the packet is PutMsg'ed
to a wild address → memory corruption or silent loss.  The
reconstruction preserves the bug (`source/rexxsupport.s`,
`h_FORWARD`, comment "DEFECT").

## 2. SHOWLIST '@' literal-list selector is dead code

`h_SHOWLIST` (+0x798): the '@' branch begins `subqw #5,d0;
bnes err18` — but `d0` is the selector *character* remainder
(always 0 for '@'), not the argstring length.  The test can
never pass, so `@<4-byte addr>` input always returns error 18
and the literal-list feature is unreachable.  (In the dead
path `a0` also still points at the stack stub, not the
argstring.)  Preserved in the reconstruction.

## 3. OPENPORT reports FALSE when the port already exists

`h_OPENPORT` (+0x65c): when exec `FindPort` succeeds the code
branches past `sne d3` — `d3` keeps whatever value the
dispatcher left in it (0 in practice) → the command returns
`0`.  So OPENPORT returns TRUE only when it *created* the port
node (rxs-198 nonzero), FALSE for pre-existing ports and
FALSE on create-failure — "exists" and "failed" are
indistinguishable.

## 4. TYPEPKT 'A' returns the argcount, not the action

`h_TYPEPKT` (+0x600): the numeric result for selector 'A' is
`moveb d2,d3` — the **low byte of the action long**, i.e. the
packet's argument count, not the action class or value.

## 5. GETARG out-of-range silently returns empty

`h_GETARG` (+0x758): index > argcount or a NULL arg pointer
produces an empty result — only a non-1/2 packet class errors
(err18).  Callers cannot distinguish "empty argument" from
"no such argument".

## 6. REPLY ignores the resultstring flag on failure

`h_REPLY` (+0x6d0): `rm_Result2` is only filled when the
result code (arg1) is zero; a failing reply drops the
resultstring argument even when the packet requested one.

## 7. STATEF/SHOWDIR call UnLock(0) on lock failure

Both handlers funnel "Lock failed" into the shared exit that
calls `UnLock(d3)` with `d3 == 0`.  DOS tolerates a zero lock;
the call is observable in the trap log.

## 8. Result-string creation failure collapses to error 3

Any rexxsyslib CreateArgstring/flatten failure on the
result-packaging path yields `d0=3` regardless of which
command ran — e.g. ALLOCMEM success + argstring failure → 3,
with the allocated memory leaked (no FreeMem on the err path).

## 9. Packed command-table overlaps (size hack, not a bug)

The 23 records for lengths 4–9 *share bytes*: the tail of a
len-N record is simultaneously the head of a len-N+1 record,
and CLOSEPORT's last trailer byte is `jtab[0]`'s high byte.
Matching still works because each section is scanned with its
own record stride; CLOSEPORT is reachable (earlier suspicion
of an off-by-one was disproved empirically).

## 10. Minor quirks

- Command names must be 4–9 characters; shorter/longer names
  return error 1 without consulting the table.
- NEXT requires an even effective address (`*(tok)+off`), odd
  → err18; BADDR/NEXT/FREEMEM/GETARG require exact 4-byte
  argstring tokens.
- 'T' (TaskReady) flatten runs under exec Disable (`d2=-1`
  passed as the rxs-210 flags arg) while every other list uses
  Forbid — TaskReady mutates too fast for Forbid alone.
- GETPKT returns the just-queued message by reading the
  pending-list `lh_TailPred` at `node+74` — a pointer
  trick instead of keeping the GetMsg result.
- An unknown command name leaves `a0` pointing into the
  command table (harmless, but observable).
- Deferred expunge: Expunge with `opencnt>0` sets DELEXP and
  returns 0; the matching Close then re-checks and expunges,
  returning the seglist.
