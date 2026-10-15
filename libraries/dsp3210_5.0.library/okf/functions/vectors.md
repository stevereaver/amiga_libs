---
type: Functions
title: dsp3210 5.0 vector map
---

# Vectors

14 LVOs (-6 .. -84). Word-offset functab at h0+0x170:
`ffff` marker, 14 signed word offsets relative to the table
base, `ffff` terminator (span h0+0x170..0x18f).

| LVO | offset | h0+ | notes |
|-----|--------|-----|-------|
| -6  | ff90 | 0x100 | Open |
| -12 | ffa0 | 0x110 | Close |
| -18 | ffba | 0x12a | Expunge (Remove + FreeMem via exec -252/-210) |
| -24 | fffc | 0x16c | reserved stub (`moveq #0,d0/rts`) |
| -30 | 0020 | 0x190 | DSPCalcLen — d32 blob size calculator |
| -36 | 00ae | 0x21e | DSPRelocate — d32 blob loader/relocator |
| -42 | 00b8 | 0x228 | internal helper (error/alloc path) |
| -48 | 081c | 0x98c | probes exec -552 (returns -7 on failure) |
| -54 | 09f0 | 0xb60 | magic-guarded block op (`0x32102011` cookie check) |
| -60 | 0a5c | 0xbcc | list walk / free (returns 0 on bad args) |
| -66 | 0a30 | 0xba0 | magic-guarded free (`0x32102011` cookie check) |
| -72 | 0a9a | 0xc0a | d32 blob dump/scanner (validates magic 0x0166/0x6601) |
| -78 | 0828 | 0x998 | probes exec -552 (returns -7 on failure) |
| -84 | 0c8e | 0xdfe | status check (tests base+0x2b, returns sne) |

Oracle results (synthetic env): -6 -> base, -12 -> 0,
-18 -> seglist, -24 -> 0, -30/-36/-42/-72 -> -1 on null args,
-48/-78 -> -7 after exec -552, -54/-66 -> 0x4ff00,
-60 -> 0, -84 -> 0 after exec -552.
Valid 1-section d32 blob: -30 -> 4 (section count), -36 -> -5
(AllocMem path). Bad magic: both -> -1.
