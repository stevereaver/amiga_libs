# rexxserdev.library 5.02 — defects & oddities

## 1. FreeMem size high-word garbage (documented upstream)

The io-free helper (code+0x1ea) reads the release size with a
bare `move.w io+18,d0` into d0 — the **high 16 bits of d0 keep
whatever the caller left there**, so `FreeMem` can receive a
hugely inflated byte count (e.g. `0xXXXX0052` instead of 82).

This is the bug the Aminet `RexxSerDevFix` package documents and
patches ("only a word sized parameter is passed into FreeMem,
possibly causing a mess").  On the observed teardown paths d0's
high word happens to be clean, so the corruption is latent, but
any caller whose d0 has nonzero high bits frees too much memory.

Reproduced in `source/rexxserdev.c` (`free_io`): the size is
computed as `(incoming_d0 & 0xffff0000) | mn_Length`.

## 2. SerFlush can never flush (dead R/W selection)

At code+0x372 SerFlush reads a mode byte from `arg+48`, then:

```
move.b  48(a1),d0
ori.b   #$60,d0          ; d0 |= 0x60  — sets bits 5,6
cmpi.b  #$52,d0          ; 'R' = 0x52 — bit5 clear → can NEVER equal
bne     try_W
…       io1
try_W:
cmpi.b  #$57,d0          ; 'W' = 0x57 — bit5 clear → can NEVER equal
bne     fail
…       io2
fail:   reply "0"
```

Because the `ori.b #$60` forces bits 5–6 on, and both compare
targets ('R'/'W') have bit 5 clear, **no input can match** — the
function always falls through and replies `"0"` without issuing
CMD_FLUSH.  Verified: oracle returns `"0"` for 'R','W','r','w',
NUL and 'x' on both binaries.  The intent was presumably a
`#0x20` case-fold or a raw compare.

## 3. SerStart / SerStop are stubs

Both API entries point at the same `bra reply("0")` — CMD_START
and CMD_STOP are never issued; the functions always report
failure.  (CMD codes 7/6 go unused.)

## 4. Dead test in LibExpunge

`expunge` does `tst.l lib+50` (open-object count) with no
conditional — the object count is never checked before teardown;
expunging frees live SerObjs' parent library regardless.

## 5. SerQuery reply depends on rxs-306's a0 semantics

SerQuery writes `"1 "` then calls the private -306 formatter
twice, using `a0` post-call as the next write position.  If the
real rexxsyslib -306 does NOT advance a0, the second field would
overwrite the first — reply `"1  <status>"` with io_Actual lost.
The oracle's -306 advances a0 (matching the author's evident
intent `"1 <actual> <status>"`); the code is faithful either way.

## 6. OpenDevice-fail path leaks nothing but order differs

On OpenDevice failure the read channel frees io then port
(`bsr 0x28e` → free_io + DeleteMsgPort) — reconstructed exactly.

## 7. 4-byte prefix stub

The code hunk opens with `moveq #0,d0;rts` before the RomTag —
probably an execution/entry placeholder.  Reproduced at code+0.
