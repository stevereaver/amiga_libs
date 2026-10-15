# Findings & defects

- Unusual build: 5 hunks with interleaved HUNK_DEBUG LINE records and a HUNK_SYMBOL tail — symbols preserved in shipping binary.
- Reserved vector -24 is a relocated-zero slot that resolves to CODE+0.
- One NULL-hole behaviour not present; all vectors except -24 have real code.
- Runtime: deterministic invalid accesses (53) under synthetic emulation; original and rebuilt traces identical.
- initfn -> h0+0x20; init returns lib base, header = name "rtggadtools.library", id "rtggadtools.library 1.0", ver 6/rev 0 node fields (pri 9).
