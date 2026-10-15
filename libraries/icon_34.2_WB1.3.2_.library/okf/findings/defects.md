# Findings & defects

- Four shipped directory copies are md5-identical — WB1.3/1.3.2/1.3.3
  labels are packaging variants of one build.
- initfn calls exec -408 + exec -108 (seglist/LVO housekeeping).
- 1019 deterministic invalid accesses; identical orig vs rebuild.
