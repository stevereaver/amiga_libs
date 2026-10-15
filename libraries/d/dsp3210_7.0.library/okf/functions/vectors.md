---
type: Functions
title: dsp3210 7.0 vector map
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
| -48 | 080e | 0x97e | shared DSP-op entry, d4=0x10001 (probes exec -552, returns -7) |
| -54 | 09e0 | 0xb50 | guarded free/dispatch (`0x32102011` cookie); 7.0: status protocol — returns saved a6 on bad args, 0 on FreeMem path, secondary-lib -60 result otherwise |
| -60 | 0af2 | 0xc62 | name lookup in (name,val) tables; 7.0: container-aware — obj+4 array then each node's +12 table |
| -66 | 0a28 | 0xb98 | guarded free; 7.0: if a0 is a `0x00fc2011` container, Removes+frees list nodes whose node@(8)==a1; else block free via sub@0xbe0 (-1/0 status) |
| -72 | 0b80 | 0xcf0 | d32 blob dump/scanner (validates magic 0x0166/0x6601) |
| -78 | 081a | 0x98a | shared DSP-op entry, d4=0x10003 (probes exec -552, returns -7) |
| -84 | 0d74 | 0xee4 | status check (tests base+0x2b, returns sne) |
| -90 | 0aa0 | 0xc10 | free-all; 7.0: if a0 is a `0x00fc2011` container, RemHead-drains embedded MinList and frees every node; else NULL-terminated pointer-array free clearing each slot on success |

Subroutine at h0+0xbe0 = 6.0's -66 guarded-free body verbatim
(cookie `0x32102011` at block-8, exec -210 FreeMem, returns -1
on success / 0 on NULL, odd or cookie-mismatch). Both -66 and
-90 fall back to it for non-container arguments.

Oracle results (synthetic env): -6 -> base, -12 -> 0,
-18 -> seglist, -24 -> 0, -30/-36/-42/-72 -> -1 on null args,
-48/-78 -> -7 after exec -552, -54 -> 0x100000 (libbase; 6.0
returned adjusted pointer 0x4ff00), -60 -> 0, -66 -> 0,
-84 -> 0 after exec -552, -90 -> input a0 (0x50000).
Valid 1-section d32 blob: -30 -> 4 (section count), -36 -> -5
(AllocMem path). Bad magic: both -> -1.
