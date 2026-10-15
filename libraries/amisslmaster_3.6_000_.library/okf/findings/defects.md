---
file: defects
---
# Findings

- Packed Resident again; InitTable in the separate DATA hunk.
- functab slot -24 is a literal ->h0+0 dead stub.
- Open returns a context pointer into the lib data area
  (per-open handle), not the lib base.
- Semaphore-guarded table ops: exec -564/-570 around every user
  vector touching the child-library registry.
