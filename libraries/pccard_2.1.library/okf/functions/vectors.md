# Vectors (7, absolute long)

-6 Open / -12 Close / -18 Expunge / -24 stub.
-30: clone a CIS tuple tag list (CloneTagItems/NextTagItem loop +
  per-tuple post-processing: CopyMem into fresh AllocVec buffers).
-36: recursive free of cloned tag structures.
-42,-48: higher-level card services built on the tuple walker.
All paths deterministic under the synthetic tuple harness.
