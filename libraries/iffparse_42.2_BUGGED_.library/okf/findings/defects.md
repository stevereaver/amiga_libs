# Findings & defects

- Marked "BUGGED" in the archive name — the real 42.2 build was
  recalled by Commodore (clipboard/IFF write-back issues);
  distributable fix is 42.3+.
- Close path decrements the open count to 0xfffe under double
  close without guard (same underflow family).
- Vector probe shows raw error-code returns (-5 IFFERR_NOFILE,
  -11, -4) matching iffparse error semantics.
