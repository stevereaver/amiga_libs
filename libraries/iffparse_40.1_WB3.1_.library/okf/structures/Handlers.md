---
type: Structure
title: Built-in handlers (.data)
description: The seven 20-byte hook objects and what they do.
timestamp: 2026-10-10T18:00:00Z
---

# Built-in handlers

Seven `struct Hook` objects in `.data`; `CallHookEntry` invokes
`hook->h_Entry` (+8) with (a0=hook, a1=msg, a2=object) and returns
`IFFERR_NOHOOK` (-11) when hook or entry is NULL.

## PropHandler (0xa7c)

Chunk handler installed by PropChunk/PropChunks.  On chunk body it
reads the whole chunk into a StoredProperty LCI
(`{sp_Size,sp_Data,data}`) stored via StoreItemInContext into the
property scope (root ContextNode when no PROP context is active).

## StopHandler (0x270)

Returns `IFF_RETURN2CLIENT` (-12) — makes ParseIFF surface the
chunk to the client.

## CollHandler (0xb14)

Collection handler: allocates a CollectionItem (`size+12`), copies
the chunk body, links it into the `'coll'` CollectionList LCI
(`{head,stop,scope}`).  On exit, items below the scope watermark
are unlinked/freed via the purge hook.

## ExitStopHandler (0x26c)

Returns `IFFERR_EOC` (-2).

## CollPurgeHook (0xc5e)

Purge callback for collection LCIs: walks the item chain, frees
items that belong to the expiring context, splices the survivors.

## DOSStreamHook (0xefa)

IFFCMD_READ/WRITE/SEEK → dos.library `Read`/`Write`/`Seek` on
`iff_Stream` (BPTR).  INIT/CLEANUP return 0.

## ClipStreamHook (0x10ca)

IFFCMD_* → clipboard.device IOClipReq commands on
`iff_Stream` (ClipboardHandle*).  WRITE sets `io_Command=CBD_WRITE`,
fills `io_Data/io_Length`, DoIO; READ uses `CBD_READ`; seeks update
`io_Offset`.  Non-seekable writes go through the deferred-write
list on the IFFHandle.
