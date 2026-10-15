---
file: vectors
---
# Vectors

6 LVOs (-6 .. -36), absolute functab@h0+0x66 ->h0:
+0x114/+0x122/+0x136/+0x186/+0x18c/+0x1a4.

initfn@h0+0xae opens dos.library + intuition.library
(exec -108 region = OpenLibrary stub label) then returns lib.
-30/-36 allocate 4 blocks each (4114/8194/8706/8194 byte
patch-table chunks) and free them — deterministic
alloc/free pattern for the EPU patch machinery.
