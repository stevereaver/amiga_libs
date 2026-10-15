# xpksqsh 1.10(older) — layouts

Stream format, workspace layout, XpkSubParams offsets, private-data
layout and return codes are identical to xpkSQSH_1.00 — see
`libraries/xpkSQSH_1.00.library/okf/structures/layout.md`.

Deltas vs 1.00 (all metadata, zero code changes):

| field | 1.00 | 1.10(older) |
|-------|------|-------------|
| idstring | `xpkSQSH 1.00 (13.10.93)` | `xpkSQSH 1.10 (6.3.94)` |
| idstr pad | string is 2 bytes longer | 2 extra pad zeros (InitTable stays at file 0x68) |
| datatab revision | 0 | 10 |
| xi_LongName | `Squash 1.0` | `Squash 1.10` |

The file is **truncated**: it ends at file offset 0x8b8 immediately
after the HUNK_END type longword (`0000 03f2`), missing the trailing
size longword. Loads fine in practice.

The identical 2,232 bytes also form a prefix of `xpkSQSH_1.10.library`
(2,936 B); the extra 704 bytes sit after HUNK_END and are dead data to
the loader (they look like a small appended code blob — `moveq #4,d5;
addq.l; moveml ...` at 0x8b8 — likely a build-time overlay, not part of
the loadable image).
