---
file: defects
---
# Findings

- Resident packed inside a 44B DATA hunk along with the
  InitTable — GCC-style resident-in-data build.
- functab is embedded at h0+4 immediately after the -1 stub.
- initfn performs a large deterministic unmapped read walk
  (0xffffff2e+ negative-address scan) under stub emulation.
- open#2 returns 0 while cnt increments — asymmetric
  re-open handling.
