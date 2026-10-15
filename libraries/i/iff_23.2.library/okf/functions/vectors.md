---
type: Function
title: iff.library 23.2 vector map
tags: [lvo, functab]
timestamp: 2026-10-15T03:43:30Z
---

# iff.library 23.2 vectors (word-offset functab, base = table @+0xa4)

| LVO | target | function |
|-----|--------|----------|
| -6   | 0x128 | Open (alloc lib-data, Forbid bookkeeping) |
| -12  | 0x170 | Close (opencnt--, deferred-expunge check) |
| -18  | 0x19c | Expunge (Remove, CloseLibrary dos, FreeMem, d0=seglist) |
| -24  | 0x1dc | RESERVED (rts stub) |
| -30  | 0x252 | OpenIFF (dos Open a0=name, mode d0) |
| -36  | 0x3a8 | CloseIFF (FreeMem iffp) |
| -42  | 0x410 | FindChunk (a0=iffp, d0=chunkid) |
| -48  | 0x440 | GetBMHD |
| -54  | 0x46c | GetColorTab |
| -60  | 0x4b4 | DecodePic |
| -66  | 0x5a4 | SaveBitMap |
| -72  | 0x5bc | SaveClip |
| -78  | 0x808 | IffError (returns -1 for null iffp) |
| -84  | 0x824 | GetViewModes |
| -90  | 0x24a | NewOpenIFF (path near -30) |
| -96  | 0x87c | ModifyFrame |
| -102/-108/-114 | 0x1dc | RESERVED stubs (share -24 target) |
| -120 | 0x1e0 | stub (rts) |
| -126 | 0x9e0 | ext func (dos Seek call trace) |
| -132 | 0xa54 | ext func (dos Write/Read) |
| -138 | 0xae0 | ext func (returns 1) |
| -144 | 0xb14 | ext func (exec RawDoFmt -624? trace: lvo -624) |
| -150 | 0xbb0 | ext func (same -624 trace) |

LVOs -126..-150 are the v23 WB2 extension functions.
