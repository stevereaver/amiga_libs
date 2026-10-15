---
type: Structures
title: xpkNUKE 1.1 layout
---

# Layout

- dataSize 0x156; DATA hunk body copied to lib+0x3a by initFn.
- Self-relocation: initFn patches 8 pointers into the copied
  data (pointer table at data+0x120, count word at +0x11c) —
  the DATA hunk holds Huffman tables + descriptor strings.
- xsp: +0 InBuf +4 InLen +8 OutBuf +12 OutBufLen +16 OutLen
  +52 xsp_Sub[0] -> 84B context + two work tables.
