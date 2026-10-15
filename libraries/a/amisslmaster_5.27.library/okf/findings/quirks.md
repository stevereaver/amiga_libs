# amisslmaster.library 5.27 — quirks and oddities

- **Non-standard RomTag**: an extra relocated long sits between
  `rt_EndSkip` and the flags/version/type/pri word, pointing at the
  logfile-name string.  And `rt_EndSkip` points back at the matchtag
  itself rather than past it — a resident scanner would loop on this
  tag.  Reproduced literally.

- **DOS handle leak**: the expunge path closes AmiSSLBase (+42) but
  never CloseLibrary's DOSBase (+46).

- **DOSBase doubles as log-enable**: every API entry calls the logger
  with ctx=+46; the logger treats a NULL context as "disabled".  If
  dos.library ever failed to open, all logging silently vanishes (and
  the Open calls would crash anyway).

- **Per-line file I/O**: every log line opens, seeks to end, writes
  and closes `RAM:awmaster.log`.  Two open attempts (MODE_READWRITE
  1004 then MODE_NEWFILE 1006).  Slow but simple — a debug build left
  in production.

- **Log buffer overflow possible**: fmt is capped at ~71 chars into a
  ~72-byte stack buffer, but the `" = <signed-decimal>"` suffix and
  newline append past the cap without a bound check.

- **TAG chain semantics are literal +8**: tag 3 continues the walk at
  `(TagItem*)(ti_Data + 8)` — not a plain `ti_Data` chain like
  TAG_MORE; ti_Data is treated as pointing 8 bytes before the next
  item.  Probably the author's TagItem-chain idiom; reproduced
  verbatim.

- **InitAmiSSLA rc: 0 = OK**: OpenAmiSSLTagList returns 0 when
  amissl's InitAmiSSLA returns 0, and 3 when nonzero — the amissl
  call's result is an error code (0 success), not a handle.

- **OpenAmiSSL ignores apiVersion**: the requested version isn't
  compared or passed to OpenLibrary (version arg is 0).

- **OpenAmiSSLCipher is a pure stub** (always 0) and CloseAmiSSLCipher
  a bare `rts` — wolfSSL-era placeholders; the cipher-open API was
  apparently planned but never implemented.

- **entry stub returns -1** (`moveq #-1; rts`) — the file is not a
  runnable CLI command (unlike iff.library's CHW! bootstrap).
