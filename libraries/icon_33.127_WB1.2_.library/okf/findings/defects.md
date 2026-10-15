# Findings & defects

- Four declared hunks are empty (size-0 records) — an artifact of
  the WB1.2 per-function linker layout.
- icon 33.127 predates the iffparse-era InitData convention; dtab
  exists (@h0+0xa4) and decodes normally.
- 0 invalid accesses; close returns the open count to 1 cleanly.
