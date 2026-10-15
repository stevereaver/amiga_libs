# Findings & defects

- Resident in CODE hunk but ALL pointer fields relocate into the
  DATA hunk (strings + InitTable there) — inverse of the usual
  cross-hunk direction.
- dtab=0: header name/ver fields are not populated by InitData —
  under the oracle they read 0 deterministically on both binaries
  (real dos fills ln_Name from the resident on AUTOINIT).
- OpenLib calls at init log name pointers that resolve through
  relocated slots (mathieeedoubbas v37, mathieeedoubtrans v34).
- 0 invalid accesses.
