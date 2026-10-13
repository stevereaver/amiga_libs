# xpksqsh 1.10(older) — defects & inconsistencies

All codec defects are identical to xpkSQSH_1.00 — see
`libraries/xpkSQSH_1.00.library/okf/findings/defects.md`
(past-end match overread, decoder copy overrun, literal run
over-emit, w9 dead-tag, stale xsp_Sub[0], output budget = inlen,
no 68020 gate).

File-level oddities specific to this binary:

1. **Truncated hunk**: file ends at 0x8b8 right after the HUNK_END
   type word — the terminating size longword is absent. AmigaOS
   LoadSeg tolerates this (the hunk is already fully described), but
   strict parsers flag it.
2. **Version mislabel**: idstring/revision/longname say "1.10" but the
   entire code is byte-identical to the 1.00 build — this is a
   relabeled 1.00, not a distinct codec revision. The real "1.10"
   content delta is presumably the 704-byte overlay appended in
   `xpkSQSH_1.10.library` (of which this file is an exact prefix).
