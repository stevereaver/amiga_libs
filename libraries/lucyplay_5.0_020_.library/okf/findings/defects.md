# Findings & defects

- initfn gate: returns 0 when its environment check fails (the
  68000 build's init succeeds under the same harness) — vectors
  remain usable regardless.
- Same close-count underflow (cnt=65535) as the 68000 build.
- 1956 deterministic invalid accesses under synthetic probing —
  higher than the 68000 build's 30, identical orig vs rebuild.
