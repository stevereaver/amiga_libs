# Findings & defects

- Close/Expunge teardown calls CloseLibrary(0) three times
  (dep bases never stored / NULL-close bug) + Remove(0) and
  FreeMem(0,0).
- Close underflows open count (cnt=65534).
- ~7 deterministic invalid reads probing functab edges.
