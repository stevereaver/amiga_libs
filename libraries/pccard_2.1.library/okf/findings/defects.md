# Findings & defects

- Close underflows the open count (traces cnt=65535 after two
  opens + one close), so remove/free paths trigger early — same
  defect class as pccard_1.1.
- Tuple clone path bound-checks tag codes loosely; the 2.1 build
  uses utility.library TagItem ops throughout.
- 0 invalid accesses.
