# xpkBLZW 3.4 — Stream format & decoder

## Packed stream

```
u16 maxwidth   -- max code width reached (mode bits if dict filled,
                  else final current width)
u16 maxlen&~3  -- deepest dictionary chain seen by the packer
                  (decoder sizes its string stack by it)
bit codes      -- MSB-first packed, starting at byte 4
```

Codes are written as `*(ULONG*)cursor |= code << bitcur` into a
sliding 32-bit window (cursor += 2 when fewer than 16 bits remain).
Bitcur starts at 32.

## Codes

| value | meaning |
|-------|---------|
| 0..255 | literal bytes |
| 256   | end of stream |
| 257   | clear: reset dictionary to 259, width to 9 |
| 258   | width++: next codes are one bit wider |
| 259.. | dictionary strings, hash-built by the packer |

Initial width 9, initial nextcode 259, width grows as the dictionary
fills (lazily — see packer.md).

## Decoder walk (orig 0x3c2)

Work buffer = `(4<<width) + maxlen`; string stack descends from
buf+maxlen, entries table occupies buf+maxlen upward:

- entries 0..255: f = -(256-c) literal markers
- 256..258: f = -32768/-32767/-32766 = end/clear/width++
- 259+: f = firstchar, prev2 = prevcode*2

Read code → entry:
- entry < nextfree → defined: if f<0 it's a marker (first-read only);
  else push f, follow prev2*2 until a marker, emit the terminal
  literal, then pop the stack.
- entry >= nextfree → KwKwK: push d6 (firstchar of previous string),
  walk the *previous* code's chain.
- dict write `{firstchar, prev*2}` gated by a dbf counter —
  `freecnt = (1<<width) - 259` writes total.

Marker dispatch is a V-flag daisy chain: `f-3` sets V for the three
specials only; `f+1` twice more distinguishes 258 (first V re-set),
257 (second V set → restart), 256 (falls out → return 0).

After 256/257/258: no dict write, `d4=2*code` skipped for specials
that jump to readnext.
