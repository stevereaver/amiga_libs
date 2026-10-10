---
type: Finding
title: Quirks
description: Defects and oddities of the shipped binary.
---

# Quirks

1. **Catastrophic empty-input loop in BOTH codecs.**
   With inlen == 0 the code still enters the shared
   kernel: `subql #1,d2` takes d2 to -1/-2 and `dbf`
   iterates ~0xfffe times, reading past the input and
   writing ~64KB beyond the output buffer.  The
   reconstruction guards `!n` and returns 0
   (outlen already 0).  Presumably unreachable in
   practice because xpkmaster never issues 0-length
   chunks.

2. **idstring overlaps the $VER: cookie.**  The
   RomTag's idstring pointer lands mid-string:
   `$VER: xpkDLTA.library v0.1` at +0x3e while
   lib_IdString points at +0x44 (`xpkDLTA.library v0.1`,
   no `$VER:`).  Reproduced via `_idstr = _verstr + 6`.

3. **RT_VERSION is 0** — a v0.1 release.

4. **Module entry returns 0** (moveq #0), not the -1 of
   most XPK sublibs.

5. **InitStruct-initialised descriptors.**  The XpkInfo
   AND XpkMode fields live in the datatab stream —
   including "ByteMode" written as two literal longs.
   Only xi_ModeDesc needs LibInit code (no base-relative
   reloc exists for InitStruct).

6. **Empty cleanup hook.**  LibExpunge `bsr`s to a lone
   `rts` before Remove — an extension placeholder.

7. **xi_Flags = 0x2000** — outside the documented
   XPKIF_PK/UP_CHUNK bits; early-API or private flag.

8. **DELEXP is textbook lib_Flags bit3**, cleared with
   `bclr` in LibOpen (vs `andib` elsewhere).
