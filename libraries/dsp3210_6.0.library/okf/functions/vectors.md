---
type: Functions
title: dsp3210 6.0 vector map
---

# Vectors

15 LVOs (-6 .. -90). Word-offset functab at h0+0x170:
`ffff` marker, 15 signed word offsets relative to the table
base, `ffff` terminator (span h0+0x170..0x191).

| LVO | offset | h0+ | notes |
|-----|--------|-----|-------|
| -6  | ff90 | 0x100 | Open |
| -12 | ffa0 | 0x110 | Close |
| -18 | ffba | 0x12a | Expunge (Remove + FreeMem via exec -252/-210) |
| -24 | fffc | 0x16c | reserved stub (`moveq #0,d0/rts`) |
| -30 | 0022 | 0x192 | DSPCalcLen — d32 blob size calculator |
| -36 | 00b0 | 0x220 | DSPRelocate — d32 blob loader/relocator |
| -42 | 00ba | 0x22a | internal helper (error/alloc path) |
| -48 | 081e | 0x98e | probes exec -552 (returns -7 on failure) |
| -54 | 09f2 | 0xb62 | magic-guarded block op (`0x32102011` cookie check) |
| -60 | 0a86 | 0xbf6 | list walk / free (returns 0 on bad args) |
| -66 | 0a32 | 0xba2 | magic-guarded free (`0x32102011` cookie check); 6.0: returns -1/0 status |
| -72 | 0ac4 | 0xc34 | d32 blob dump/scanner (validates magic 0x0166/0x6601) |
| -78 | 082a | 0x99a | probes exec -552 (returns -7 on failure) |
| -84 | 0cb8 | 0xe28 | status check (tests base+0x2b, returns sne) |
| -90 | 0a64 | 0xbd4 | NEW in 6.0: NULL-terminated pointer-array free — calls -66 per slot, clears slot on success |

Oracle results (synthetic env): -6 -> base, -12 -> 0,
-18 -> seglist, -24 -> 0, -30/-36/-42/-72 -> -1 on null args,
-48/-78 -> -7 after exec -552, -54 -> 0x4ff00, -60 -> 0,
-66 -> 0 (5.0 returned the adjusted pointer 0x4ff00),
-84 -> 0 after exec -552, -90 -> input a0 (0x50000).
Valid 1-section d32 blob: -30 -> 4 (section count), -36 -> -5
(AllocMem path). Bad magic: both -> -1.
