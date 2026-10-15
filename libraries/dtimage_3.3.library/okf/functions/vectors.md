---
file: vectors
---
# Vectors (6 abs-long @h1+0x10)

-6 Open ->h0+0x6c | -12 Close ->h0+0x84 |
-18 Expunge ->h0+0xa6 | -24 ->h0+0xf2 |
-30 ->h0+0x2b8 | -36 ->h0+0x3e6.

initfn @h0+0xe: exec -294 then OpenLibrary dos40,
intuition40, graphics40, utility37, datatypes39.
-30: OpenLibrary "datatypes/picture.datatype" v43,
CloseLibrary dance, lib2 calls — image-acquire path.
-36 similar with a different class name arg.
