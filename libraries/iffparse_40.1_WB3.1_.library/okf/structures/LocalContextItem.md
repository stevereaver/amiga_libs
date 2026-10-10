---
type: Structure
title: LocalContextItem (internal)
description: 24-byte LCI header + caller data.
resource: source/iffbase.h
timestamp: 2026-10-10T18:00:00Z
---

# LocalContextItem internals

`AllocLocalItem(type,id,ident,dataSize)` does
`AllocVec(dataSize+24, MEMF_CLEAR)`.  The 24-byte header:

| offset | field |
|-------:|-------|
| 0x00 | `struct MinNode lci_Node` |
| 0x08 | `ULONG lci_ID` |
| 0x0c | `ULONG lci_Type` |
| 0x10 | `ULONG lci_Ident` |
| 0x14 | `struct Hook *lci_Purge` — purge hook (private, invisible to clients) |

Caller data follows at +0x18 (`LocalItemData` returns `lci+24`).
Evidence: AllocLocalItem stores id@+8, type@+0x0c, ident@+0x10;
SetLocalItemPurge stores a1 at +0x14; FreeLocalItem is `FreeVec`.

## Built-in LCI payloads

- `'prop'` → StoredProperty: `{ LONG sp_Size; APTR sp_Data; data[] }`
- `'coll'` → CollectionList: `{ head, stop, scope }` (12 bytes);
  CollectionItems are `size+12` blocks: `{ next, size, data, bytes[] }`
- `'ehnd'`/`'exhd'` → handler payload `{ hook, object }` (8 bytes)
