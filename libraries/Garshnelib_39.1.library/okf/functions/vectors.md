---
file: vectors
---
# Functab entries (@h0+0xf8c, abs-long + 0xffffffff term)

-6 +0xc4 open (opencnt++/flag clear) | -12 +0xd6 close
(deferred-expunge check) | -18 +0x100 expunge path |
-24 NULL hole (table entry 0, uninstalled) |
-30..-90 library funcs: +0x158 +0x2fa +0x4c6 +0x54c
+0x5be +0x882 +0x90a +0x986 +0xa58 +0xb5e +0xe22 +0x45c.

No negative jump table is built — the API surface is the
stored functab pointer (lib+0x38) plus a forward pointer
table at lib+0x3c copied from hunk1 (values like
h0+0xf00/0xe10/... plus ascending small offsets). Hosts
dispatch through the table directly.
