# epu1.library — defects & quirks (verbatim in recon)

1. **datatab dead write**: first InitStruct entry writes BYTE 9 at
   base+0x0c — the middle of `ln_Name`; overwritten immediately by the
   following `initlong @0x0a`.  `ln_Type` (@8) is never set by the
   datatab.
2. **Stale IntuiText chain link**: the third requester text node keeps
   its template `NextText` into the static data records, so the
   AutoRequest body chain trails two extra NULL-text nodes
   (harmless on real intuition, verbatim quirk).
3. **Remove called via a0**: LibExpunge passes the node in a0;
   exec `Remove` documents a1.  Reproduced verbatim.
4. **Infinite open retry**: if `lh.library` cannot be opened the init
   loop shows the requester and retries forever — the AutoRequest
   result (RETRY or CANCEL) is ignored.
5. **Dead dosbase mirror**: init stores the dos base twice — to
   base+38 and to code-hunk slot 0x30c; the slot is never read.
6. **Dialog line order is upside-down**: IntuiText TopEdges 3/13/23
   display arg3, arg2, arg1 top-to-bottom, so the OOM requester reads
   `<callname>` / `Name of call is` / `epu1 error:Out of memory` and
   the open-failure requester reads `lh.library` / `can not open` /
   `epu1.library` — the intended messages appear reversed.
7. **Post-hoc bound check**: pack/unpack compare the lh result against
   the caller's a1 bound *after* the operation already ran; -2 reports
   the overrun but cannot prevent whatever lh already wrote.
