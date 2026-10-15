# Findings & defects

- initfn AttnFlags gate returns 0 under the stub harness on both
  builds (consistent with the doubbas/doubtrans siblings).
- Requires the extended 040 line-F emulation (fmovem +
  fs*/fd* aliases) added for mathieeedoubtrans_40.6_040_.
