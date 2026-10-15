# queue.library 3.1 — OKF index

`queue.library` 3.1 (03.12.96) — Bernhard Fastenrath's (SHW Wabnitz)
multi-task message-queue library (AmiNet `util/libs/queue.lzh`, GPL).
Several tasks write to a named queue, several others read; used by the
`shutdown` command. SAS/C build; the .c/.h sources were published in the
archive.

- binary: `binary/queue_3.1.library` (2836 bytes, 3 hunks)
- source: `source/queue.s` — pure 68k asm (gas)
- build: `cd source && make` → byte-identical (md5 `c36710f623b4186980b10b35847dfd2a`)
- oracle: `work/oracle.py` (machine68k, fake exec with real MinList
  semantics + AUTOINIT emulation) — init, all 9 API vectors, lifecycle
  (deferred expunge). Orig vs rebuild trace identical.

## Layout

- hunk0 CODE 0x26b longs (0x9ac B): `moveq #0,d0;rts` entry stub /
  LVO -24 vector, RomTag (RTF_AUTOINIT, ver 3, NT_LIBRARY, pri 0),
  `__UserLibInit` + SAS/C 28-byte globals-template copy loop with its
  pointer-rebase fixup pass (empty), Open/Close/Expunge, helpers
  (SetMarker/ClearMarker/RemoveAndReply/ReplyQMessage/NewList-clone),
  and QOpen/QClose/QAddMsg/QRemMsg/QGetMsg/QReplyMsg/QFlush/
  QAllocMsg/QFreeMsg.
- hunk1 DATA 8 longs (32 B): pad long + AUTOINIT InitTable
  (dsize=0x8c, functab->hunk2, datatab=0, initfn->hunk0+0x20) + three
  zero longs; last long doubles as the fixup-table count (0).
- hunk2 CODE 0x17 longs (0x5c B): 13-entry absolute-longword functab,
  `0xffffffff` terminator, "queue.library\0", "queue.library 3.1\0",
  trailing "#$".

## Quirks

- Overlapped instructions: `cmpiw #0x1cd9,d0` hides
  `move.b (a1)+,(a6)+` (init copy loop); `cmpiw #0x200d,d0` hides
  `move.l a5,d0` (init success/fail join).
- All RELOC32 groups list offsets in *descending* order.
- The entry stub doubles as the LVO -24 null vector.
- QueueHandle union overlays the listener marker MinNode onto the
  sender reply-list Tail/TailPred fields.
- QClose reads a possibly-uninitialized stack slot (compiler artifact).

See `functions/vectors.md`, `structures/layout.md`,
`findings/quirks.md`, `log.md`.
