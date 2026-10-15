# Findings & defects

- Directory names it 37.7 but the embedded $VER says 37.8 — a
  version-tag inconsistency in the archive.
- Close decrements open count to 0xfffe on double close
  (unguarded, same underflow family).
- Massive (230.9M) deterministic invalid pointer probing during
  deep vector calls — identical on orig and rebuild.
- init calls exec -408 (OpenResource pattern) 3x with the dep
  name strings — unusual resource-style probing of lib names.
