# asyncio.library 37.2 — OKF index

`asyncio.library` 37.2 (5.1.96) — Martin Taillefer / Magnus Holmgren.
Asynchronous double-buffered file I/O implemented on top of dos.library
packets: OpenAsync returns an async-file object with two bounce buffers
and a pending-packet state machine; ReadAsync/WriteAsync/SeekAsync and
the char variants drive non-blocking transfers.

- binary: `binary/asyncio_37.2.library` (2640 bytes, 2 hunks)
- source: `source/asyncio_h0.s`, `source/asyncio_h1.s` — pure 68k asm
- build: `cd source && make` → byte-identical (md5 `f723fbc9472de7efcc8e51ce6515c66a`)
- oracle: `work/oracle.py` (machine68k, fake exec+dos+utility plus a
  fake instant-reply dos handler on a 300-byte backing file) — init,
  open×2, all vectors (OpenAsync read+write, buffered ReadAsync across
  buffer boundaries+EOF, SeekAsync, Read/WriteCharAsync, CloseAsync,
  close, expunge); `run_O.log` vs `run_R.log` identical

## Layout

- hunk0 CODE 2448B: null vector + functab *before* the RomTag
  (h0+4..0x33), InitTable, init, Open/Close/Expunge, 8 async-IO
  vectors, packet/lock helpers, strings
- hunk1: 20-byte BSS globals `{libbase, execbase, UtilityBase, DOSBase,
  seglist}` reached via `lea 0:l,a4` (RELOC32 → hunk1)

See `functions/vectors.md`, `structures/layout.md`, `findings/quirks.md`,
`log.md`.
