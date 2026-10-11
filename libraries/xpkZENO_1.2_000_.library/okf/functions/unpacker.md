# xpkZENO 1.2 — XpksUnpackChunk

LZW unpacker, single output pass.

## Header handling

```
u32 hash   if nonzero: pwhash(xsp_Password) must equal it, else -32
u8  bits   max width actually used in the stream
u8  flags  (name-length; ignored)
```

- Stream hash != 0 and password missing/wrong -> -32.  Empty
  password hashes to 0, so a missing password only fails on
  streams that were packed with one.
- `bits` byte is trusted: `D3 = (1<<bits)+0x800` sizes the
  tables; the unpack workmem comes from the mode descriptor.

## Bit reader

MSB-first.  First code is the top 9 bits of the stream
(`long >> 23`); subsequent codes read `width` bits across the
long boundary the same way the packer wrote them.

## Dictionary expansion

- `T_code u16[D3]` (slot/code), `T_pref`, `T_char` — same layout
  as the packer, indexed by code (not hashed).
- Each new code emits the string it stands for via a stack walk:
  follow `T_pref`-chain pushing `T_char`, then drain the stack.
- KwKwK case (code == nextcode): the first character of the
  previous string is pushed — `firstchar` is seeded from the
  very first literal code.
- After emitting, `{oldcode, firstchar}` is appended at
  `nextcode++`; width grows when `nextcode` reaches the current
  `maxcode` (same rule as the packer, 9 -> bits).
- Code 0x101: tables are cleared (memset of `T_pref` and
  `T_code[128..]`), `nextcode = 0x104`, width/maxcode restart
  at 9/0x1ff, and the next code is read as a fresh literal
  (direct output byte path, like the stream head).
- Code 0x100: end of stream.

## Error paths

- `AllocMem` fail -> -7.
- Wrong/missing password on hashed stream -> -32.
- Truncated stream runs off the end without a length check on
  input — `xsp_InLen` is never consulted while decoding; the
  loop terminates on 0x100 or when the output buffer fills.

Verification: byte-exact round-trips on all tested inputs
incl. the adaptive-reset stream; independent code-stream reader
confirms width growth and EOI placement.
