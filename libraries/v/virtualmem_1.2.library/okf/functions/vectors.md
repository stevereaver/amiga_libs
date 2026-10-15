---
file: vectors
---
# Vectors (17 abs-long @h1+4)

-6 Open +0xa2 | -12 Close +0xb4 | -18 Expunge +0xcc |
-24 stub +0x11a | -30..-102 user funcs at
+0x4ca/+0x64a/+0x71a/+0x7ba/+0x83c/+0x960/+0xaf0/+0xb5a/
+0xc8c/+0xd72/+0xdee/+0xe56/+0xf28.

All funcs run under Obtain/ReleaseSemaphore pairs
(lib+0x5a area), AllocMem(10240) buffer ops, Remove/list
ops. -90 returns its arg (0x1111), -102 returns -1.
initfn @h0+0x30: OpenLibrary dos v37 + multiuser.library
v39, then a lib2 call + CloseLibrary x2 under stubs.
