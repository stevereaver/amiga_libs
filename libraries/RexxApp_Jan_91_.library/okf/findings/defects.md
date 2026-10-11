# Findings & shipped quirks — rexxapp.library

## Defects / suspicious behavior (reproduced verbatim)

1. **Verb fold quirk** — the case-insensitive verb compare only
   fold-matches command chars whose `|0x20` form is in (97,122)
   exclusive: `'a'` and `'z'` never match an uppercase verb char.
   `subb d1,d0;bhis` uses unsigned 'a'≥c1 and `cmpib #122;blss` cuts at
   'z' — both boundaries exclusive.

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

- `rexxapp_lib.s` reproduces the stub/RomTag/vector-table/node/init
  block byte-for-byte (lifecycle code at hunk+0x9c..0xd6 identical).
- C side rebuilt with `-ffixed-a5` so gcc never allocates the ABI
  register; all LVO calls go through named-register inline asm.
- Callback conventions differ per site — see structures/context.md.
