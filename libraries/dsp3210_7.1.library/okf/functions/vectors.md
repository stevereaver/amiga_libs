---
file: vectors
---
# Vectors (word-offset functab)

15 vectors: -6 Open, -12 Close, -18 Expunge (Remove +
FreeMem), -24 stub, -30/-36 D32 blob load ops (magic
check; -36 allocs), -42/-48/-72 container ops (-48/-78
FreeMem-36 teardowns), -54 status, -60 keyed lookup,
-66 free-by-key, -84 list teardown (FreeMem-36), -90
container drain (returns list base). Valid-blob calls
verified in oracle; bad-magic -> -1.
