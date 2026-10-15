# Vectors (45, word-offset functab)

-6 Open / -12 Close / -18 Expunge / -24 stub, then the full
iffparse API (-30..-270): AllocIFF/FreeIFF/OpenIFF/CloseIFF/
ParseIFF/FindChunk/ReadChunkBytes/WriteChunkBytes/
CurrentChunk/EntryHandler/PropChunk/CollectionChunk/StopChunk/
Clipboard hooks etc. Deterministic under synthetic IFF buffers;
error returns (-5/-11/-4/-1) reproduce exactly.
