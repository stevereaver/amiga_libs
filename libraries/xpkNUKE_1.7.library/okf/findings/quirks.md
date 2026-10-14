# xpkNUKE 1.7 — quirks & inconsistencies

1. idstr lacks the `$VER:` cookie: `"xpkNUKE 1.7 (06.06.1997)"`.
2. The `_start` stub at code+0 returns -1 (`moveq #-1,d0; rts`)
   (sic) — hunk entry never meant to run.  Also: PackChunk stores
   pack_core's raw return at `xsp+16`, so a failing pack writes
   `0xffffffff` there, not an error code.
3. Seglist is kept in a code-segment slot (code+0x7a), not in the
   library base — older-generation skeleton.
4. Hash/tab AllocMems are NOT cleared by the AllocMem flags; the
   PackChunk wrapper memsets both tables every call.
5. Match window edge test is `cmp.w d4,d6; bls` — a candidate at
   or *below* `d4 = d5-window` (incl. the d6=0 chain sentinel when
   d4=0) discards the just-found better match and ends the search;
   same `bls` semantics as 1.9.  An early reconstruction draft used
   `<` and diverged (ramp/txt/rnd8k).
6. Literal-tail copy runs when litptr >= outcur — the overflow check
   only fails when outcur *passes* litptr; 1.9 fails at equality too.
7. -30 PackerInfo's descriptor pointers live in the DATA hunk —
   embedded absolute addresses differ between orig and any rebuild.
