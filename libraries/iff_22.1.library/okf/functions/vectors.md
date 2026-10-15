---
type: Function
title: iff.library 22.1 vector map
tags: [lvo, functab]
timestamp: 2026-10-15T00:00:00Z
---
# iff.library 22.1 vectors (word-offset functab @+0xa2, leading+trailing 0xffff)

Target = functab base (+0xa2) + word.

| LVO | word | target |
|-----|------|--------|
| -6   | 0x0084 | 0x126 Open |
| -12  | 0x00cc | 0x16e Close |
| -18  | 0x0104 | 0x1a6 Expunge |
| -24  | 0x014a | 0x1ec RESERVED stub |
| -30  | 0x01c0 | 0x262 OpenIFF |
| -36  | 0x0322 | 0x3c4 CloseIFF |
| -42  | 0x038a | 0x42c FindChunk |
| -48  | 0x03ba | 0x45c GetBMHD |
| -54  | 0x03e6 | 0x488 GetColorTab |
| -60  | 0x042e | 0x4d0 DecodePic |
| -66  | 0x051e | 0x5c0 SaveBitMap |
| -72  | 0x0536 | 0x5d8 SaveClip |
| -78  | 0x0782 | 0x824 IffError (-1 for null) |
| -84  | 0x079e | 0x840 GetViewModes |
| -90  | 0x01b8 | 0x25a NewOpenIFF |
| -96  | 0x07fa | 0x89c ModifyFrame |
| -102/-108/-114 | 0x014a x3 | 0x1ec reserved stubs |
| -120 | 0x014e | 0x1f0 stub |
| -126 | 0x095e | 0xa00 ext func (dos Seek trace) |
| -132 | 0x09c2 | 0xa64 ext func |
| -138 | 0x0a3e | 0xae0 ext func |
| -144 | 0x0a72 | 0xb14 ext func (RawDoFmt/CopyMem trace) |
| -150 | 0x0b0e | 0xbb0 ext func (RawDoFmt/CopyMem trace) |
