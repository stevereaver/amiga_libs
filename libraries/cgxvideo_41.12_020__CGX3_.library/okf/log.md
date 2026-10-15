---
file: log
---
# Work log

- 2026-10-15: cgxvideo 41.12 (020)(CGX3) — 4-hunk
  AUTOINIT phase5 CGX3 video/overlay lib. 15 abs-long
  vectors (SDK fd names: CreateVLayerHandleTagList,
  DeleteVLayerHandle, AttachVLayerTagList, DetachVLayer,
  GetVLayerAttr, LockVLayer, UnlockVLayer,
  SetVLayerAttrTagList + 4 reserved stubs). Lazy dep-open
  at first Open (expansion/dos/utility/intuition/layers/
  graphics v39 + cgxsystem v41 + FindResident
  cybergraphics); patchtab in DATA h1 SetFunctions 2 of 6
  'CYBI' records into layers -180/-168. Verbatim .byte
  reconstruction (cgx_h0..h3.s) + pooled-resplit fixup:
  BYTE-IDENTICAL (md5 d241854485ba9987729dabb3b0de82a8).
  Oracle (initfn + 2xOpen + 15 vecs + 6 armed CYBI stubs
  + Close/Expunge): orig.log == rebuild.log, ~25M
  deterministic invalids. Plane AMIGALIBS-407.
