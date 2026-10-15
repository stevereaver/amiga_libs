# rebol 0.2.library — OKF index

## Identity

| field    | value                                                                 |
|----------|-----------------------------------------------------------------------|
| libname  | `rebol.library`                                                       |
| version  | 0.2 — `"$VER: rebol.library 0.2 (07.07.2001) (22:55:56/© 2000, 2001 Jean Holzammer <Development@Holzammer.net>)"` |
| source   | Aminet `RebolLib` (July 2001), Jean Holzammer; repo binary is byte-identical to `RebolLib/Libs/rebol.library` in the archive |
| size     | 2908 bytes (hunk), CODE body 2780 bytes                               |
| format   | hunk: header + CODE(0x2b7 longs) + RELOC32 + END                      |
| resident | AUTOINIT (`rt_Flags = 0x80`), rt_Version 0, NT_LIBRARY, pri 0         |
| purpose  | Thin bridge to a `Rebol` executable: `RebolDo(source)` wraps the source in a `REBOL []` script that `write/binary`s its result to `T:RebolLibResult.<n>`, launches `Rebol -cs` via `SystemTagList`, then reads the result file back. `RebolFreeResult(result)` releases the buffer. Per-task contexts are kept in a slot list (up to 255 tasks per node). |

## Public API

| LVO | name            | registers | semantics |
|-----|-----------------|-----------|-----------|
| -6  | Open            | a6=lib    | OpenCnt++; finds/allocs a ctx slot for `SysBase->ThisTask`, builds a 3896-byte ctx (opens dos/intuition/graphics v33). |
| -12 | Close           | a6=lib    | dec slot count; on 0 tears down ctx (closes con fh, ctx freelist, libraries, buffer). On OpenCnt 0 calls Expunge and returns the seglist. |
| -18 | Expunge         | a6=lib    | busy->0; clears a once-only "survive" flag the first time; otherwise frees ctx nodes, Remove+FreeMem(lib), returns seglist. |
| -24 | stub            |           | `moveq #0,d0; rts`. |
| -30 | RebolDo         | d0=source | Full dos.library pipeline (see vectors.md). Returns result string ptr (AllocVec'd) or 0. |
| -36 | RebolFreeResult | d0=result | FreeVec(result); accepts 0. Returns 0. |

## Reconstruction

- **Approach**: single GAS source `source/rebol.s` transcribing every
  instruction verbatim; non-`bs` GAS relaxation points (`pea (d16,PC)`,
  `movel d0,sp@(0)` zero-displacement form, CMP-immediate `b0bc/b03c/b47c`
  EA forms vs CMPI, `bset d2,d1`, abs-long `jsr`/`jmp`/`moveal 4:w`
  encodings) emitted as raw `.short` pairs.
- **Build**: `source/Makefile` + `source/fixup.py` (rewrites the hunk
  tail to restore the original non-sorted RELOC32 offset order).
- **Result**: byte-identical — MD5 `8248998dac7f1d1b5f236fb67fc12745`.
- **Runtime**: `work/oracle.py` under machine68k — real m68k RawDoFmt
  injected (it must call the library's putch callback), dos.library
  stubs, ctx-slot/Open/Close/deferred-Expunge, RebolDo success +
  GetVar/Open/Lock failure paths, RebolFreeResult — traces identical
  for original vs rebuilt.

## Docs

- `functions/vectors.md` — vectors + every internal helper.
- `structures/layout.md` — hunk map, RomTag/InitTable/datatab, ctx.
- `findings/quirks.md` — endSkip oddity, unchecked AllocMem, the
  uninitialized ctx fields, scratch-buffer contamination, misc bugs.
- `log.md` — work log.
