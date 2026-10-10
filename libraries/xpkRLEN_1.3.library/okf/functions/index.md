# Functions

| LVO | Symbol | Role |
|-----|--------|------|
| -6  | LibOpen | openCnt++, clear LIBF_DELEXP, return base |
| -12 | LibClose | openCnt--; expunge when 0 + DELEXP pending |
| -18 | LibExpunge | deferred-expunge; Remove + FreeMem |
| -24 | LibNull | moveq #0,d0/rts (own stub at hunk+0x100) |
| -30 | XpksPackerInfo | `lea xpkinfo,a0` — absolute into data hunk |
| -36 | XpksPackChunk | pack one chunk |
| -42 | XpksPackFree | stub (shared moveq#0/rts at hunk+0x130) |
| -48 | XpksPackReset | stub (same) |
| -54 | XpksUnpackChunk | unpack one chunk |
| -60 | XpksUnpackFree | stub (same) |

Notes:

- Module entry (hunk+0) is `moveq #-1,d0; rts` — the resident
  *function* entry returns -1, unlike the +0 stubs.
- The function table is an absolute-longword table (no word-offset
  marker), 10 entries + -1 terminator.
- LibInit/LibExpunge `bsr` a shared `moveq #0,d0; rts` stub — the
  classic user-init/user-cleanup hooks compiled to no-ops.
- The encoder uses the `cmpiw #<imm>,d0` trick twice to hide the
  loop's `moveq #0,d0` / `addql #1,d7` at the following word: a
  branch lands inside the cmpiw's immediate word.

- [XpksPackChunk.md](XpksPackChunk.md)
- [XpksUnpackChunk.md](XpksUnpackChunk.md)
