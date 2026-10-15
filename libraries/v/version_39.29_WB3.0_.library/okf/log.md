# version39.29WB3.0 — RE log

- 272 B, single CODE hunk 48 lw. Parsed RomTag + packed strings
  + InitTable + word-mode functab; all offsets resolved.
- Transcribed source/version.s (shares template with the other
  WB version stubs). `.byte 0` pad after idstr (not word).
- `make` -> byte-identical, md5 713334015c2300ea4100de0dc2afc4c5.
- No oracle: only external call is exec FreeMem(-210) in the
  last-close expunge path; behavior covered by byte identity.
