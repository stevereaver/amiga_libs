# streplay 33.8 — quirks and findings

## Self-modifying code

The library keeps *all* of its runtime state inside the CODE hunk —
there is no DATA/BSS hunk at all. Player globals are written with
absolute-long addressing while reads are PC-relative:

- `_tick` (0x826): incremented in place by `addqw #1,0x826:l`.
- `_speed` is not a variable — it is the **low byte of the immediate**
  of `cmpiw #6,_tick:l` @0x37a. `_setspeed` and effect EF both write
  a byte at hunk+0x37f.
- `_modbase` (0x900): written `movel a0,0x900:l` in `_setup`, read back
  `moveal %pc@(0x900),a0`.
- `_samtab`, `_patidx`, `_patoff`, `_patptr`, `_songlen`, `_dmamask`,
  `_patbreak` all self-modified the same way.

Consequence: the library is inherently single-instance per loaded copy;
its state lives in (nominal) ROM-space within the hunk.

## Shared-rts branch quirk

`_freebuf`'s empty path (`beqs`) and both `_close` exits branch to the
`rts` **inside Open** at 0x110 — not to the adjacent `rts` at 0x102 that
ends `_freebuf`. Byte-identical reconstruction must route these branches
to the shared target.

## Tail-jump vectors

`Play` and `Stop` set/clear the flag word and then `jmp` (absolute)
to `_play2`/`_stop2` — the vector entries have no `rts` of their own;
the tail returns. `_stop`'s "not playing" exits branch *backward* to the
shared `rts` at 0x110.

## Interrupt server

Play installs a VBLANK (`INTB_VERTB`, 5) server via AddIntServer;
`is_Data`=0 (handler receives no context — all state is the hunk
globals). The node is a static struct inside the CODE hunk named
`"STReplay_Lib Interrupt"`.

## LoadModule size detection

File size is obtained by `Seek(fh, 0, OFFSET_END)` then
`Seek(fh, 0, OFFSET_BEGINNING)` — the second Seek's return value (the
*previous* position) is the size. OldOpenLibrary's result is never
checked: if `dos.library` fails to open the code jsr's via a6=0 and
crashes.

## Encoding quirks (for byte-identical builds)

- `movel %pc@(sym),%a0` must be used — `moveal %pc@(sym),%a0` makes gas
  emit absolute-long addressing instead of `207a` PC-rel.
- The InitStruct datatab `e0`-form entries are 6 bytes (word-aligned);
  a pad byte follows the stream terminator.
- The period table is followed by 6 pad bytes before `_modbase` @0x900.
- The original linker emitted the single RELOC32 list in a
  partially-descending order (…0x282,0x28a then 0x22e,0x216 then the
  low header offsets); `fixup.py` rewrites GNU ld's ascending order.

## IsPlaying return value

Returns the raw playing word (0x525a), not a boolean — callers must
treat it as nonzero-true. `0x525a` looks like a magic more than a flag.

## Song data model

31-instrument (ProTracker-era) module; `_setup` derives the pattern
count by scanning the 128-byte position table for its maximum, builds
sample start addresses in `_samtab[1..31]` (slot 0 unused), and reads
song length from module offset 0x3b6 into `_songlen`'s low byte.
