# accounts.library 37.5 — OKF index

`accounts.library` 37.5 (1.3.93) — Commodore **Envoy** NIPC client library.
An RPC front-end for the remote "Accounts Server" service: public vectors
build a request object via `nipc.library` (tag `0x800b1101` = request
size), drop a single command byte (`'j','k','l','m','n','o','p','q','t',
'u'`) at obj+28, and synchronously ship it through a per-call reply port.
Also contains small alloc/free record helpers and a password-hashing
routine.

- binary: `binary/accounts_37.5.library` (2756 bytes, 1 hunk)
- source: `source/accounts.s` — pure 68k asm (gas)
- build: `cd source && make` → byte-identical
  (md5 `56b6d8fc21a9ef9b53564ab6509bc994`)
- oracle: `work/oracle.py` (machine68k; fake exec + dos + utility + nipc)
  — rt_Init/initfn, Open (incl. nipc/ctx/service failure paths),
  deferred-expunge via Close, all 19 vectors, dead sprintf helper.
  Orig vs rebuilt logs identical.

## Layout

- Single CODE hunk, 0x29c longs (2672B body): -1 stub, RomTag
  (AUTOINIT, ver 37, NT_LIBRARY), strings, InitTable (dsize=0xf4),
  **word-offset** functab (leading `0xffff`, 19 vectors), datatab
  (`INITWORD lib_Revision=5`), initfn, Open/Close/Expunge, record
  alloc/free pairs, 10 RPC request vectors, password hash, and three
  internal helpers (mkobj/sendreq/strncpy) plus a dead RawDoFmt
  sprintf wrapper.
- 8 RELOC32 relocs, all hunk0→hunk0, stored in original order
  `0xa,0x6,0x12,0x16,0x1a,0x4c,0x50,0x54` (EndSkip before MatchTag).

## Highlights

- Everything funnels into one synchronous RPC pattern:
  `mkobj(size)` → fill data block (+0/+32/+40 strings, +32/+64/+104
  word/long fields) → `sendreq` (CreateMsgPort → nipc -156
  transaction → WaitPort/GetMsg/DeleteMsgPort) → read status at
  obj+30 → `nipc -120` free.
- Open lazily opens `nipc.library`, creates a context, reads the
  `Envoy/AccountsServer` env var (dos GetVar) as the host hint, and
  finds the `Accounts Server` service — all under a per-library
  semaphore at lib+62 (magic `0xc0edbabe` at lib+108).
- Node fields (ln_Type/ln_Name/flags/version/idstring) are NOT set by
  initfn — left for exec's InitResident RomTag machinery; only
  `lib_Revision=5` comes from the datatab.

See `functions/vectors.md`, `structures/layout.md`,
`findings/quirks.md`, `log.md`.
