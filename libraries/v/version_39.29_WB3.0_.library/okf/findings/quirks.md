# version39.29WB3.0 — quirks

- Expunge vector (-18) is a `moveq #0` stub: the library can never
  be expunged by exec, but Close expunges unconditionally the moment
  opencnt hits 0 (no LIBF_DELEXP test). Open->Close pair removes it.
- Revision is not in the RomTag; initfn writes `movew #29,a5@(22)`
  — ver comes from RomTag, rev from code.
- No datatab: ln_Type/ln_Name/lib_Flags never set by the lib
  (AUTOINIT exec path may leave type 0); the lib exists purely for
  `version` command / OpenLibrary probing.
- idstr carries `\r\n` terminator.
