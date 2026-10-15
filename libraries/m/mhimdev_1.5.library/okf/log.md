# mhimdev 1.5 — reconstruction log

## Parse

- 2608 B: HUNK_HEADER → 1×HUNK_CODE (0x25b longs) → RELOC32(36) → END.
- RomTag @0x0a: `4afc`, matchtag→0x0a, endskip→0x158, flags 0x80.
- **Correction**: earlier analysis misread 0x80 as RTF_COLDSTART —
  `RTF_AUTOINIT` is bit 7 (0x80) per exec/resident.h; this is a standard
  AUTOINIT library. rt_Init→0x158 = InitTable `[0x2a,→0xfc,→0x138,→0xe6]`.
- Functab @0xfc: 14 absolute longs + `ffffffff`. datatab @0x138 uses the
  embedded-offset InitStruct form (8=long, 9=word, a=byte-high, 0=end);
  relocs at 0x13e/0x150 are the name/idstr pointer data.

## Decode

- vbcc-style compiled C: `linkw a5` frames, `moveml` save/restore,
  register args (handle in **a3** — device-driver convention), stack
  args for leaf helpers, gcc-style `__mulsi3`/`__udivmodsi4`/`__divmodsi4`
  runtime at 0x8b8/0x8e0/0x938, static `{0,1}` at 0x964.
- API surface identified as MHI driver ops for `mpeg.device`:
  AllocDriver(task,sigmask) / FreeDriver / QueueBuffer(CMD_WRITE via
  SendIO, pooled 86 B ioreqs) / GetDoneBuffer (softint-filled donelist,
  node recycled to freelist) / GetStatus / Start / Stop(drain+FLUSH) /
  Pause(toggle via ioreq1+56 + cmd 10) / Query / SetVolume(cmd 20,
  {L,R,-1} words).
- AllocDriver reads env var `MHIMDEV` through dos ReadArgs
  `DEVICE,UNIT/N`; defaults to empty devname when dos or the var is
  absent; opens `test.device`/whatever was parsed.
- port1 runs PA_SOFTINT with an embedded Interrupt inside the handle
  (is_Code=0x860, is_Data=handle); the handler drains port1's list into
  the donelist, decrements pending, and Signals the caller's task.

## Reconstruction

- Pure-asm transcription `source/mhimdev.s` — single file covers
  romtag/tables/strings/all code/runtime.
- Built with `m68k-amigaos-gcc -m68000 -nostdlib -nostartfiles -s`.
- `fixup.py` rewrites the RELOC32 offset list to the original's
  non-sorted order (ascending segments interleaved with a descending
  functab block — same linker quirk as streplay/write).
- Iterated byte-diff: `moveal a2,d2`→`movel` fix; internal div entry
  `_divreg` at 0x8e6 for the signed wrapper's reg-arg calls.

## Verification

- File byte-identical: MD5 `9fb62cb3abdf99e13433a74e0ea34712`.
- `work/oracle.py` (machine68k, stubbed exec+dos with real list/port
  emulation): identical logs orig vs rebuild — makelib header, 20 query
  values incl. string returns, AllocDriver trace (GetVar→ReadArgs→
  OpenDevice→sendcmd RESET), QueueBuffer→pending, softint reply→
  Signal→GetDoneBuffer returns buf, pause/start state machine,
  volume cmd-20 payload `[0xcccc,0xcccc,0xffff]`, Stop drain,
  FreeDriver cascade, deferred expunge.
- Edge paths identical: allocfail→NULL handle, no-dos→empty devname.
