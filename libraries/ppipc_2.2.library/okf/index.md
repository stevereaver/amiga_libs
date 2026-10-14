# ppipc.library 2.2 — OKF index

`ppipc.library` 2.2 (89:04:17) — a PowerPC↔68k IPC port broker. It keeps
an internal list of "MsgPort-like" objects (50+name bytes each), signals
their owners on demand, and can ask a `PortBrokerPort` service to
register/activate a port by sending it an `'IPPL'`/`'PORT'` request
message. Companion to the PowerUP-era WarpOS PPC library set.

- binary: `binary/ppipc_2.2.library` (2644 bytes, 11 hunks)
- source: `source/ppipc_h0.s` … `ppipc_h10.s` — pure 68k asm
- build: `cd source && make` → byte-identical (md5 `22686832f5b26d0c8d0c57e3746c5c5c`)
- oracle: `work/oracle.py` (machine68k) — lifecycle + all 22 vectors
  traced, orig vs rebuild output identical
- plane: (none filed)

## Layout

- hunk0 CODE 0xb0: `moveq#20,rts` stub + RomTag (AUTOINIT v1) + NewList /
  strlen / strcpy helpers reached via jmp stubs
- hunk1 DATA 0x38: InitStruct datatab (24-bit-offset commands) + SysBase
  cell at +0x32
- hunk2 DATA 0xa0: name + idstr + ver/rev words + 22-entry functab +
  InitTable @ +0x8a
- hunk3 CODE 0xe8: initfn, Open, Close, Expunge, null vector
- hunk4 DATA 0x04: seglist cell
- hunk5 CODE 0x3c0: port object allocator + vectors -30..-90
- hunk6 BSS  0x10: internal port list head (exec `MinList`-style)
- hunk7 CODE 0x134: -96 BrokerRequest + row of jmp stubs into h5/h10
- hunk8 DATA 0x10: `"PortBrokerPort"` name
- hunk9 CODE 0x84: -102 Str2ID, -108 FindID
- hunk10 CODE 0x28: GetMsg/WaitPort wrappers that reload SysBase from
  hunk1+0x32 (a6 need not be exec)

See `functions/vectors.md`, `structures/layout.md`,
`findings/quirks.md`, `log.md`.
