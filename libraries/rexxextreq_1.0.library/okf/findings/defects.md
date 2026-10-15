# Findings & defects

- Triple-cross-hunk metadata: resident in h0 names strings in h2
  and an InitTable in h1 which points back at a functab in h2
  whose entries relocate into h0 — a maximally scattered build.
- h2 is a CODE hunk holding the functab + strings (no executable
  code) — tag/type mismatch quirk.
- 0 invalid accesses; open-count handled sanely (cnt=1 after
  close).
