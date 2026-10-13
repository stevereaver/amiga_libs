# RunBar 1.0 — RE session log

## Phase 1 — inventory

- 2156B, three hunks: CODE 0x704, DATA 0x24, DATA 0x58.
- RomTag@code+4, AUTOINIT; rt_Init -> hunk1+4 (data hunk),
  InitTable {0x194, functab->hunk2+0, datatab 0, initfunc
  ->code+0x20}; datatab NULL -> header filled manually.

## Phase 2 — disassembly

- 12-entry LONG functab, register-parameter ABI (a6=base,
  args d0/a0..a3).
- Identified: 15-of-16 slot registry, anonymous MsgPorts,
  CreateMsgPort/DeleteMsgPort clones inline (incl. the
  ln_Type=0xff / lh_Head=-1 poisons), synchronous 28-byte
  request messages, Forbid/Permit-bracketed PutMsg.
- Trickier bits resolved: mid-instruction `beq` landing on a
  `movel a5,d0` operand (init return), stale-d0 return values
  (RB_Remove locked -> 1, drains -> last msg ptr), template
  copy reading 92B past the data hunk.

## Phase 3 — reconstruction

- runbar.c with __asm-bound register params (no stubs needed);
  exec primitives via `moveal 4:w,a6` + jsr a6@(LVO).
- runbar_lib.s: RomTag + .data {pad, InitTable, globals,
  verstr ptr, fixup count, 92B zero pad} + functab + strings.
- Bug found by oracle: RBObj's name@+2/flag@+6 are PACKED
  (unaligned) — initial C struct had them at +4/+8.

## Phase 4 — verification (Musashi 68000)

- Oracle emulates Forbid/Permit, AllocSignal/FreeSignal,
  AllocMem(clear)/FreeMem, FindTask, Add/RemPort, PutMsg/
  GetMsg/ReplyMsg/WaitPort (real list semantics), Remove.
- 20-call scripted exercise (add/dup/namedup/null, lock,
  locked-remove, unlock, send, update, remove, table-full at
  15, teardown, reset, open/expunge/close): return values
  identical, exec-call log identical (322 entries), priv image
  identical modulo relocated pointers.
