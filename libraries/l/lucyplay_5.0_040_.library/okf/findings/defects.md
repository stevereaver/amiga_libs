# Findings & defects

- initfn gate: returns 0 when its environment check fails (the
  68000 build's init succeeds under the same harness) — vectors
  remain usable regardless.
- Same close-count underflow (cnt=65535) as the 68000/68020 builds.
- 1956 deterministic invalid accesses under synthetic probing —
  identical to the 68020 build's signature, orig vs rebuild.
