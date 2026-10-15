---
file: defects
---
# Findings

- initfn returns 0 under stub emulation (dep/setup fails)
  — vectors still install and run; deterministic.
- "lowlevel" XPK flavour: the chunk ABI differs from
  xpkSHR/xpkHFMN — pack calls return raw addresses, the
  ctx bookkeeping of the sublib family is absent.
- PackerInfo has a single mode desc ("Wow!!", upto=100).
