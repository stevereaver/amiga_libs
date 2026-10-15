---
type: Findings
title: xpkNUKE 1.1 quirks
---

# Findings / quirks

- PackFree frees the 3 allocs but leaves xsp+52 pointing at the
  freed 84B context — callers reusing the xsp get stale state
  (oracle 'realloc' path exercises this harmlessly).
- XpkUnpack always returns rc=0 — even on garbage input;
  outlen comes from caller-preloaded xsp+16, not the stream.
- 'allb' (all-zero 256B) pack returns rc=-17 (XPK_EFILEFMT?);
  'tiny-outbuf' and 'rand64' also -17 — packer rejects inputs
  it can't represent rather than clipping.
- allocfail propagates rc=-7 (memory) and leaves outlen
  untouched (0xdeadbeef sentinel preserved).
