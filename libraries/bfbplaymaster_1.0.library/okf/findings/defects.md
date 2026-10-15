---
type: Findings
title: bfbplaymaster 1.0 quirks
---

# Findings / quirks

- InitStruct datatab present but lib carries minimal extra
  state — most user vectors return canned error codes when
  replayer sublibs can't be opened.
- Module sniff uses a magic-word table; 'XPKF' entries map to
  'XPK packed modules are not supported!' — deliberate
  rejection, not a missing codec.
- 'Master library already in use!' — singleton gate in Open.
