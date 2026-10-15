# Findings & defects

- initfn returns 0 under the stub harness — OldOpenLibrary for
  dos.library isn't stubbed (returns 0), matching orig behavior.
- 0 invalid accesses; open/close count sane.
