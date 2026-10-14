# freeanim.library 40.29 — quirks

- Whole library is a stub: functab word-mode entries all point at
  one `moveq #0,d0; rts`, which doubles as initfn and all four
  vectors. Open returns 0 -> every OpenLibrary of it "fails" at
  the API level even though exec lists the resident.
- EndSkip = 0x6a points past the stub code into pad (normally
  skips to a data address after the tag; here it just skips the
  one stub).
- initfn returning 0 under AUTOINIT leaves a lib whose negative
  vector area exists but where Open yields NULL — placeholder
  semantics (name on disk, no function).
- Strings are byte-packed (idstr at odd 0x2f, 1-byte pad at 0x49).
