---
type: Index
title: Functions (LVO map)
timestamp: 2026-10-10T18:00:00Z
---

# Function table

45 vectors; word-offset table (see [../structures/InitTable.md](../structures/InitTable.md)).


## System vectors

- `-6` [LibOpen](LibOpen.md)
- `-12` [LibClose](LibClose.md)
- `-18` [LibExpunge](LibExpunge.md)
- `-24` [LibNull](LibNull.md)

## Basic

- `-30` [AllocIFF](AllocIFF.md)
- `-36` [OpenIFF](OpenIFF.md)
- `-42` [ParseIFF](ParseIFF.md)
- `-48` [CloseIFF](CloseIFF.md)
- `-54` [FreeIFF](FreeIFF.md)

## Read/Write

- `-60` [ReadChunkBytes](ReadChunkBytes.md)
- `-66` [WriteChunkBytes](WriteChunkBytes.md)
- `-72` [ReadChunkRecords](ReadChunkRecords.md)
- `-78` [WriteChunkRecords](WriteChunkRecords.md)

## Context push/pop

- `-84` [PushChunk](PushChunk.md)
- `-90` [PopChunk](PopChunk.md)
- `-96` [LVO -96 (reserved)](Reserved96.md)

## Handlers

- `-102` [EntryHandler](EntryHandler.md)
- `-108` [ExitHandler](ExitHandler.md)
- `-114` [PropChunk](PropChunk.md)
- `-120` [PropChunks](PropChunks.md)
- `-126` [StopChunk](StopChunk.md)
- `-132` [StopChunks](StopChunks.md)
- `-138` [CollectionChunk](CollectionChunk.md)
- `-144` [CollectionChunks](CollectionChunks.md)
- `-150` [StopOnExit](StopOnExit.md)

## Context utilities

- `-156` [FindProp](FindProp.md)
- `-162` [FindCollection](FindCollection.md)
- `-168` [FindPropContext](FindPropContext.md)
- `-174` [CurrentChunk](CurrentChunk.md)

## LocalContextItem

- `-180` [ParentChunk](ParentChunk.md)
- `-186` [AllocLocalItem](AllocLocalItem.md)
- `-192` [LocalItemData](LocalItemData.md)
- `-198` [SetLocalItemPurge](SetLocalItemPurge.md)
- `-204` [FreeLocalItem](FreeLocalItem.md)
- `-210` [FindLocalItem](FindLocalItem.md)
- `-216` [StoreLocalItem](StoreLocalItem.md)

## Init

- `-222` [StoreItemInContext](StoreItemInContext.md)
- `-228` [InitIFF](InitIFF.md)
- `-234` [InitIFFasDOS](InitIFFasDOS.md)

## Clipboard

- `-240` [InitIFFasClip](InitIFFasClip.md)
- `-246` [OpenClipboard](OpenClipboard.md)

## Misc

- `-252` [CloseClipboard](CloseClipboard.md)
- `-258` [GoodID](GoodID.md)
- `-264` [GoodType](GoodType.md)
- `-270` [IDtoStr](IDtoStr.md)
