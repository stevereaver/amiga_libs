---
bundle: dg8svx_2.1.library
status: complete
updated: 2026-10-15
---
# dg8svx.library 2.1 (15.7.94) (c) Optonica Ltd

8SVX/IFF sample-streaming player library: chunk-list walker,
Fibonacci-delta decoders, mono/stereo feeder and a tag-arg
playback pump. Deps opened lazily at first Open: dos,
graphics (WaitTOF), toolkit (list/copy/hook helpers), dgiff
(file/chunk IO), dgaudio (channel playback). 2 hunks:
h0 CODE 0x51a longs + h1 DATA 0xf longs (base slots, tick
stub, defaults, fib table). AUTOINIT ver 2, 12 abs-long
vectors (-6..-72). RELOC32 49 slots (24->h0, 25->h1).

- `structures/layout.md` — hunk map, resident, InitTable, data hunk
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks (misdirected ln_Type write)
