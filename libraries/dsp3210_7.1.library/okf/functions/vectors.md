---
type: Functions
title: dsp3210 7.1 vector map
---

# Vectors

15 LVOs (-6 .. -90). Word-offset functab at h0+0x172:
`ffff` marker, 15 signed word offsets relative to the table
base, `ffff` terminator (span h0+0x172..0x193). The offset
words are **byte-identical to 7.0** — every target moved +2
along with the table.

| LVO | offset | h0+ | notes |
|-----|--------|-----|-------|
| -6  | ff90 | 0x102 | Open |
| -12 | ffa0 | 0x112 | Close |
| -18 | ffba | 0x12c | Expunge (close secondary lib via -414 if open, Remove + FreeMem via exec -252/-210) |
| -24 | fffc | 0x16e | reserved stub (`moveq #0,d0/rts`) |
| -30 | 0022 | 0x194 | DSPCalcLen — d32 blob size calculator |
| -36 | 00b0 | 0x222 | DSPRelocate — d32 blob loader/relocator |
| -42 | 00ba | 0x22c | internal helper (error/alloc path) |
| -48 | 080e | 0x980 | shared DSP-op entry, d4=0x10001 (opens dos.library, probes exec -552) |
| -54 | 09e0 | 0xb52 | guarded free/dispatch (`0x32102011` cookie); status protocol — returns saved a6 on bad args, 0 on FreeMem path, secondary-lib -60 result otherwise |
| -60 | 0af2 | 0xc64 | name lookup in (name,val) tables; container-aware — obj+4 array then each node's +12 table |
| -66 | 0a28 | 0xb9a | guarded free; if a0 is a `0x00fc2011` container, Removes+frees list nodes whose node@(8)==a1; else block free via sub@0xbe2 (-1/0 status) |
| -72 | 0b80 | 0xcf2 | d32 blob dump/scanner (validates magic 0x0166/0x6601) |
| -78 | 081a | 0x98c | shared DSP-op entry, d4=0x10003 |
| -84 | 0d74 | 0xee6 | status check (tests base+0x2b, returns sne) |
| -90 | 0aa0 | 0xc12 | free-all; if a0 is a `0x00fc2011` container, RemHead-drains embedded MinList and frees every node; else NULL-terminated pointer-array free clearing each slot on success |

Subroutine at h0+0xbe2 = the shared guarded block free
(cookie `0x32102011` at block-8, exec -210 FreeMem, returns -1
on success / 0 on NULL, odd or cookie-mismatch). Both -66 and
-90 fall back to it for non-container arguments.

All routines are byte-identical to 7.0 modulo the shift map in
`structures/layout.md` — no vector logic changed.

Oracle results (synthetic env, dos stubbed live): -6 -> base,
-12 -> 0, -18 -> seglist (exec -414/-252/-210 when secondary
lib open), -24 -> 0, -30/-36/-42/-72 -> -1 on null args,
-48/-78 -> -9 (dos -84 Open->handle, -102, -90 Close, two
exec -198/-210 rounds, dos -30/-42 — deeper than 7.0's -7
because OpenLibrary succeeds), -54 -> 0x100000 (libbase),
-60 -> 0, -66 -> 0, -84 -> 0xff (probe flag set), -90 -> a0.
Valid 1-section d32 blob: -30 -> 4, -36 -> 0 with an
AllocMem+FreeMem pair (alloc succeeds, later stage unwinds).
Bad magic: both -> -1. Container fixtures: -60 hits the +4
table (0xdeadbeef) and node +12 tables (0xcafe), misses -> 0;
-66 removes+frees the keyed node (exec -252/-210); -90
RemHead-drains and frees nodes; -54 dispatches through
a1@(38) -> secondary -60.
