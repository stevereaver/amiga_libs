# rexxsupport.library 36.9 — defects & oddities

All 34.9 quirks carried over verbatim (handler bodies are
instruction-identical), plus the new dispatcher/init
oddities in §1–3.

## New in 36.9

### 1. DeleteArgstring(NULL) on the error paths

The dispatcher unconditionally calls rxs-132 on the pushed
scratch pointer.  On unknown-name (d0=1) or when the
`CreateArgstring(0,400)` itself failed, that pointer is 0 —
a `DeleteArgstring(NULL)` call is observable on every failed
or unknown dispatch.

### 2. Scratch argstring alloc/fail asymmetry

`CreateArgstring(0,400)` failure → err3, but the *scratch*
pointer (0) is still passed to DeleteArgstring on the way out.
A successful dispatch that then fails result packaging also
frees the scratch and reports d0=3 — the handler's partial
work (e.g. an AllocMem'ed block, a queued packet) is not
rolled back.

### 3. T+136 silently ignored

34.9 read the caller's result buffer from `*(a5+20)+136`.
36.9 never touches it — callers that pre-seeded a buffer for
34.9 see no difference (the scratch is invisible to them),
but T+136 corruption no longer affects the library either.
`OpenLibrary("rexxsyslib.library", 0)` likewise weakens the
init contract: any rexxsyslib version binds.

## Carried over from 34.9 (unchanged)

### 4. FORWARD replies to a stale port pointer (real defect)

`h_FORWARD` (+0x6c0): after `FindPort(arg1)` succeeds
(`movel d0,d3`), the code does

```
Remove(msg);  moveal d2,a0;  PutMsg(d2, msg)
```

`a0` is loaded from **d2 — a register never set in this path**
(left over from the name-scan/arg conversion), not from `d3`
(the found MsgPort).  On a real system the packet is PutMsg'ed
to a wild address → memory corruption or silent loss.
Preserved (`source/rexxsupport.s`, `h_FORWARD`, "DEFECT").

### 5. SHOWLIST '@' literal-list selector is dead code

The '@' branch begins `subqw #5,d0; bnes sl_bad` — but `d0` is
the selector *character* remainder (always 0 for '@'), not the
argstring length.  `@<4-byte addr>` always returns error 18;
the literal-list feature is unreachable.

### 6. OPENPORT reports FALSE when the port already exists

When exec `FindPort` succeeds the code branches past
`sne d3` — `d3` keeps 0 → returns `0`.  TRUE only when the
port node was *created* (rxs-198 nonzero); "exists" and
"failed" are indistinguishable.

### 7. TYPEPKT 'A' returns the argcount, not the action

`moveb d2,d3` — the **low byte of the action long**, i.e. the
packet's argument count.

### 8. GETARG out-of-range silently returns empty

Index > argcount or a NULL arg pointer produces an empty
result; only a non-1/2 packet class errors (err18).

### 9. REPLY ignores the resultstring flag on failure

`rm_Result2` is only filled when the result code (arg1) is
zero; a failing reply drops the resultstring argument even
when the packet requested one.

### 10. STATEF/SHOWDIR call UnLock(0) on lock failure

The shared exit calls `UnLock(d3)` with `d3 == 0`; DOS
tolerates it.  Observable in the trap log.

### 11. Result-string creation failure collapses to error 3

Any CreateArgstring/flatten failure on the result-packaging
path yields `d0=3` regardless of which command ran — e.g.
ALLOCMEM success + argstring failure → 3, with the allocated
memory leaked.

### 12. Minor quirks

- Command names must be 4–9 characters; shorter/longer names
  return error 1 without consulting the table.
- Packed command-table overlaps: sections for different name
  lengths share bytes; CLOSEPORT's trailer is `jtab[0]`'s
  high byte (a size hack, works correctly).
- NEXT requires an even effective address; BADDR/NEXT/FREEMEM/
  GETARG require exact 4-byte argstring tokens.
- 'T' (TaskReady) flatten runs under exec Disable (`d2=-1`
  → rxs-210 flags) while every other list uses Forbid.
- GETPKT returns the just-queued message by reading the
  pending-list `lh_TailPred` at `node+74`.
- An unknown command name returns with `a0` left pointing into
  the command table (stale pointer — harmless, observable).
- Deferred expunge: Expunge with `opencnt>0` sets DELEXP and
  returns 0; the matching Close re-checks and expunges,
  returning the seglist.
