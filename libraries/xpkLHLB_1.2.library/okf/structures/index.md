---
type: Structure
title: xpkLHLB 1.2 structures
tags: [layout, xpk]
timestamp: 2026-10-15T00:00:00Z
---

# xpkLHLB 1.2 structures

## Library base (dataSize 0x30)

| off | field |
|-----|-------|
| 0x00 | LN (14B) |
| 0x0e | lib_Flags / lib_pad (bit3 = DELEXP after deferred expunge) |
| 0x10 | lib_NegSize 60 / lib_PosSize 82 @0x16 |
| 0x20 | opencnt (u16) |
| 0x22 | seglist (u32, BSS chunk BPTR-style, +0x5a in hunk order) |
| 0x26 | SysBase |
| 0x2a | spare/reserved long |

## XpkSubParams (as consumed, a0)

| off | use by this library |
|-----|---------------------|
| 0x00 | InBuf (pack+unpack) |
| 0x04 | InLen |
| 0x08 | OutBuf |
| 0x0c | OutBufLen |
| 0x10 | OutLen (result written here by both pack and unpack) |
| 0x30 | caller workspace ptr — NOT read (context advances past it) |
| 0x34 | xsp_Sub[0]: pack ctx / unpack state owner |
| 0x38 | xsp_Sub[1]: pack 36864B staging scratch |

Because the pack code uses `a3@+` twice before reading `a3@(48)`,
fields are consumed relative to xsp+8: OutBufLen bounds-check is
against xsp+0x0c, the copy source is xsp+0x38 (scratch), and the
packed length lands in xsp+0x10.

## Embedded blocks (CODE-relative)

| off | block |
|-----|-------|
| 0xde | XpkMode: {100, flags=1, "normal"} |
| 0x108 | XpkInfo: name "LHLB", lname "preprocessor for lh.library", desc "Fast and good compression usable for all data", flags 9, max/def chunk 0x8000, defmode 100 |
| 0x57a-0x7f6 | static hash/tab table (~636B) |
| 0xb04-0xb84 | static table (~128B) |
