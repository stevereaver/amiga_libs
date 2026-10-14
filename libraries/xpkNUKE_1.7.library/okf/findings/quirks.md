# xpkNUKE 1.7 — quirks & inconsistencies

1. idstr lacks the `$VER:` cookie: `"xpkNUKE 1.7 (06.06.1997)"`.
2. Entry stub returns -1 (sic) instead of 0.
3. Seglist is kept in a code-segment slot (code+0x7a), not in the
   library base — older-generation skeleton.
4. Hash/tab AllocMems are NOT cleared by the AllocMem flags; the
   PackChunk wrapper memsets both tables every call.
5. Match window edge test is `d6 < d4` (blss); 1.9 uses `d6 <= d4`.
6. Literal-tail copy runs when litptr >= outcur — the overflow check
   only fails when outcur *passes* litptr; 1.9 fails at equality too.
7. -30 PackerInfo's descriptor pointers live in the DATA hunk —
   embedded absolute addresses differ between orig and any rebuild.
