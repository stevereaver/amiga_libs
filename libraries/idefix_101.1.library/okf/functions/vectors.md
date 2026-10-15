# Vectors (15, absolute long -> h0)

-6 open / -12 close / -18 expunge / -24 stub; -30..-90 idefix
ATAPI/IDE hooks: -36 returns 0x3c, -42 0x7c (struct sizes),
-48 = -1 sentinel. Vectors 4,13,14 share the h0+0 stub
(moveq#0,rts). Two vector entries (idx 13,14) are dead stubs.
