# Findings & shipped quirks — rexxapp.library

## Defects / suspicious behavior (reproduced verbatim)

1. **Verb fold bound** — the case-insensitive verb compare folds the
   *input* char (`bset #5,d1`) and requires the folded form in
   ['a','z'] **inclusive**: `subb d1,d0;bhi` misses when c1<97 and
   `cmpib #122,d1;bls` misses when c1>122.  Empirically (oracle):
   "PAZ" fold-matches "paz" (so 'a' AND 'z' both fold), while
   "["/"{" (|0x20='{'>z) and "@"/"`" (|0x20='`'<a) miss.  Only the
   case-fold path is guarded — already-equal chars match before the
   check, so mixed/uppercase verbs still work case-sensitively.

2. **fwd_reply drops string results** — the forward-completion helper
   (0x3b2) calls setresult with a0=0; when the forwarded msg returns
   r1==0 with RXFF_RESULT set, the client's r2 is overwritten with 0 —
   a delivered result string is silently discarded.

3. **WaitPort arg reuse in cleanup** — the drain loop at 0x178 calls
   WaitPort with a0 left over from the previous dispatch iteration
   (works only because exec/GetMsg leave a0=ctx).  Reproduced as an
   explicit `WaitPort(ctx)`.

4. **Pending accounting** — pending++ only when !RXFF_NONRET and the
   matching -- only inside freemsg, so NONRET sends never count; a
   pending==255 blocks sends ("Too many") but cleanup waits anyway.

5. **a0 error-string sideband** — send vectors return the msg in d0 but
   leave the *last* error-string pointer in a0 even on success
   ("Can't find Rexx server"); callers must test d0, not a0.

6. **freemsg arg0 free** — on any send failure the raw cmd pointer is
   passed to DeleteArgstring when !RXFF_STRING; when the argstring
   conversion itself failed the pointer is 0 (safe), but a validator
   failure frees the already-created argstring — correct, yet the same
   path also runs on FindPort failure.

## Structural quirks

- Old-style **non-AUTOINIT** layout: library node/base carved out of the
  code hunk at hunk+0x72; LibInit calls `AddLibrary` directly.
- Resident id pointer lands *inside* the full string: file holds
  `"(dissidents Jan 91) rexxapp.library"` while the id field points at
  `dissidents…` (skips `"(`, keeps `)` — off-by-one quirk).
- Second hunk is `HUNK_CODE` size 0 (vestigial).
- Null vectors (`jmp hunk+0`) carry RELOC32 entries just like real ones.
- `rexxsyslib` vector -96 is private/undocumented — used to convert a
  result string pointer to its argstring header (+8 skip).
- App context lives in register **A5**, owned entirely by the caller.

## Reconstruction notes

- `source/RexxApp_h0.s` is a verbatim 68k transcription (gas
  %-register syntax): stub/RomTag/14-entry jmp table/node template/
  init and all bodies assemble byte-for-byte; the 21 RELOC32 fixups
  come out in original order.
- `source/fixup.py` rewrites the linked hunk header (1 hunk → the
  original 2-hunk table `[0x162, 0]`) and appends the vestigial empty
  `HUNK_CODE`/`HUNK_END` tail — byte-identical, md5
  `1724406df58c813c7db58aef2ff35320`.
- `work/oracle.py` (machine68k): identical deterministic logs on
  original vs rebuild across all vectors and error paths.
- Callback conventions differ per site — see structures/context.md.
