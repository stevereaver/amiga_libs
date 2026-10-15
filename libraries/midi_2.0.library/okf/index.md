# midi_2.0.library

"MIDI Library v2.0 (21 Oct 1988)" — early third-party MIDI
library. 6372B, 3 hunks: CODE 0x5ec + DATA 0 (empty!) + BSS 1.

- Resident @h0+4 (flags 0x80, ver 7); InitTable@h0+0x7a:
  dsize 0xc0, ftab@h0+0x8a (32 abs-long vectors ->h0),
  dtab@h0+0x10e, initfn@h0+0x146.
- init opens dos.library 33, allocates MsgPorts + signals via
  exec -558/-564/-570 + AllocMem, registers "midi" ports.
- RELOC32: 56 slots ->h0.
