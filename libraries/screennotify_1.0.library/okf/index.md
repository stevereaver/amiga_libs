# screennotify 1.0.library — OKF index

## Identity

| field    | value                                                        |
|----------|--------------------------------------------------------------|
| libname  | `screennotify.library`                                       |
| version  | 1.0 — `"$VER: screennotify.library 1.0 (26.3.95)"`           |
| size     | 2608 bytes                                                   |
| format   | hunk: CODE(2408 B body, 29 relocs) + DATA(8 B body, 24 B alloc) + END |
| resident | COLDSTART (`rt_Flags = 0x00`), rt_Init builds the lib with MakeLibrary |
| purpose  | task-notification library: clients register MsgPorts to be told when screens close, when PubScreenStatus changes a screen's public/private state, and when the WorkBench opens/closes |

## Reconstruction

- **Approach**: pure 68k assembly, byte-identical target (vbcc-style
  compiled C; `linkw` frames, register args a0/d0/a1, exec calls via
  the `exg d2,a6` / push-lib-base idiom).
- **Source**: `source/screennotify.s`, `source/Makefile`,
  `source/fixup.py` (patches hunk-1 alloc size 2→6 longs and rewrites
  RELOC32 to the original linker's non-sorted order).
- **Result**: `screennotify.library` byte-identical to the original
  (MD5 `228be5ea5285cf4aa8591a2c34fb2309`).
- **Runtime**: `work/oracle.py` — full battery traced identically
  (init fields, 3 notify objects, hook install, broadcasts on all 4
  patched intuition vectors, node add/remove incl. contended-semaphore
  drain path, deferred expunge, wrapped-handler expunge abort).

## Layout

| offset    | contents                                                      |
|-----------|---------------------------------------------------------------|
| 0x000     | `moveq #-1,d0;rts` prefix stub                                |
| 0x004     | `"screennotify.library\0"`                                    |
| 0x019     | idstring (43 B, runs into RomTag — no pad)                    |
| 0x044     | RomTag: matchtag→self, endskip→functab, ver 1, NT_LIBRARY     |
| 0x05e     | functab: 10 long-absolute entries, `-1` terminated            |
| 0x08a     | `_initobj`: NewList+InitSemaphore+embedded msg/port setup     |
| 0x0ca     | rt_Init: MakeLibrary(dsize=410), fill node, init 3 objects, AddLibrary |
| 0x192..   | Open / Close / Expunge / null                                 |
| 0x2a2     | `"intuition.library\0"`                                       |
| 0x2b4..   | intuition wrappers + broadcast/add/remove helpers             |
| 0x832..   | public API vectors -30..-60 (register/unregister ×3 classes)  |
| 0x926..   | dead stack-arg wrappers + MinList helpers + pad stubs         |
| hunk 1    | DATA: +0 SysBase, +4 LibBase, +8..+20 saved intuition vectors |

See `functions/vectors.md`, `structures/layout.md`,
`findings/quirks.md`, `log.md`.
