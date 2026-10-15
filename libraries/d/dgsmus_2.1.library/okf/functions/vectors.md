---
file: vectors
---
# Vectors (abs-long functab @h0+0xbe, 21 entries)

-6 Open @h0+0x144: on first open OpenLibrary()s dos /
graphics / toolkit / dgaudio / dg8svx / dgiff into
data+4..+0x18 (any failure unwinds via the close-all
helper and returns 0); bumps opencnt@lib+0x20, clears
lib_Flags bit3, returns libbase.
-12 Close @h0+0x25c: decrements opencnt; at zero closes all
six sublibs (CloseLibrary -414) and expunges if bit3 set.
-18 Expunge @h0+0x276: defers (sets lib_Flags bit3) if open
count nonzero, else exec Remove + FreeMem(lib-negsize,
negsize+possize=0x84); returns seglist.
-24 reserved stub @h0+0x2b4: moveq#0/rts.
-30 command dispatcher @h0+0x2b8: D0 -> -1-terminated
longword cmd list (1:next long -> arg, 5:next long -> ctx
ptr, 2/0xffff/0x10002: set flag bit2, 3/0x10003: clr bit0,
4/0x10004: clr bit1); calls dgiff -42 tag-filter, walks a
song list calling toolkit/dgaudio/dg8svx vectors, then
conditionally LIBFUNC_9/11/13.
-36 @h0+0x4dc: recursive chunk-walk — dispatches on
longword tags at elem+34 ('CAT '=$43415420 etc.; some tags
recurse, one CopyMems a 4-byte name, one allocates 300B via
exec AllocMem + toolkit -36 insert, another allocs 60B).
-42 @h0+0x608: global reset — zeroes data+0x120..(0x12c*2
bytes) and +0x10c.., stores chip-sample ptr (SECSTRT_2) at
data+0x180, inits a tk-style head @+0x10c (pri 0x20ab?),
then LIBFUNC_3 on scratch table.
-48 @h0+0x666: builds the 11-slot per-channel rate/pointer
triplets table on a song struct from header fields
(+104 ptr, +96..+100).
-54 @h0+0x724: channel/note init — sets stream ptr/len/end
on a channel ctx, calls LIBFUNC_6 lookup.
-60 @h0+0x772: the sequencer tick — walks a byte stream
(note bytes -> dgaudio -66 keyed plays via rate table,
0x80 -> wait via dgaudio -60, 0x81 -> LIBFUNC_6 lookup,
0x84 -> tempo change via LIBFUNC_7, 0x86 -> LIBFUNC_7),
returns nonzero while playing.
-66 @h0+0x922: find channel ctx by id byte +28 in list @A0
(falls back to data+0x120 scratch ctx).
-72 @h0+0x968: fixed-point tempo calc — exec byte @+530
(232 PAL/NTSC?) *240 * ... / data+0x68 word -> data+0xf0/0xf4.
-78 @h0+0x9b8: note->period lookup, 6-bit index into
data+0x68 word table.
-84 @h0+0x9e2: play/start — guards LIBFUNC_12, LIBFUNC_2
reset, claims up to 4 channel tokens (dgaudio -42 or mask
decode when D0!=0), LIBFUNC_4 per channel, LIBFUNC_7,
graphics WaitTOF (-270), per-channel LIBFUNC_5, then
LIBFUNC_15 -> AddTask(LIBFUNC_14) or LIBFUNC_10 unwind.
-90 @h0+0xb3e: stop — LIBFUNC_16 (RemTask+FreeMem 22B task
block), per-channel dgaudio -60 free + toolkit -42 remove +
-54 release of the -42 tokens.
-96 @h0+0xbc6: busy-wait — dos.library Delay(10) (-198),
loops while LIBFUNC_12 says playing.
-102 @h0+0xbea: "is playing" — returns data+0xec != 0.
-108 @h0+0xc02: song teardown — frees elem chain via
toolkit -42 + exec FreeMem (0x12c / 75*4 / 60 blocks),
dgiff -36 frees the list head.
-114 @h0+0xc96: player task body (installed by LIBFUNC_15 /
AddTask) — per-tick LIBFUNC_5 on each channel, watches
data+0x260, calls LIBFUNC_10 when idle.
-120 @h0+0xd0a: spawn player task — exec AllocMem 22B,
node type 2/pri 0 init, exec AddTask(LIbfUNC_14, task, 5).
-126 @h0+0xd56: remove player task — RemTask + FreeMem.

h0 tail (0xd80..0xe6c): compiler runtime — signed 64/32
divide helper and 32x32->64 multiply helper used by -72.
