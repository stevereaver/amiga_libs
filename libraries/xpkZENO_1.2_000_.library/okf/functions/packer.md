# xpkZENO 1.2 — XpksPackChunk

LZW-family packer over a hash-probed dictionary.

## Stream header

```
u32 hash    pwhash(xsp_Password) if first password long != 0, else 0
u8  bits    max code width 12/13/14 (mode 1-33/34-66/67-100; 0->1, >99->99)
u8  0       name-length byte (always 0)
```

followed by MSB-first packed codes.

## Dictionary

Three parallel tables sized `D3 = (1<<bits) + 0x800`:

- `T_code u16[D3]` — hash slot -> dictionary code
- `T_pref u16[D3]` — hash slot -> `prevcode+1` (0 = free)
- `T_char u8[D3]`  — hash slot -> extension byte

Only `T_pref` needs clearing to invalidate entries (0 prev is
illegal); the original also clears `T_code[128..]` on reset.

**Hash**: `h = ((byte << (bits-8)) ^ prevcode+1) & 0xffff`.
On probe collision: restart `h = 0x7ff + (byte<<(bits-8))`,
then `h = (h + prevcode+1) & 0xffff`, folding `h -= modulus`
when `h >= bound`.  Per-width modulus words are read out of a
literal table in the code stream: 12->0x1003, 13->0x2011,
14->0x47fb (the table has a 15-bit slot 0x87f7 that is
unreachable because modes cap at 14).

## Coding

- width starts at 9, `nextcode` starts at 0x104.
- codes 0-0xff literals, 0x100 EOI, 0x101 dictionary reset,
  0x102/0x103 unused.
- On each miss: emit `prevcode`, insert `{prev,byte}->nextcode++`
  (insertion stops once `nextcode == (1<<bits)-1`, i.e. one slot
  early — codes mask-1/mask are never issued as entries).
- Growth happens in `emit`: before writing a code, if
  `nextcode >= maxcode && width < bits`, `maxcode = maxcode*2+1`
  and `width++`.
- Loop ends emitting `prevcode` then 0x100.

## Bit emitter

32-bit MSB-first accumulator.  `bitspace -= width`; on overflow
(`bitspace <= 0`) a fresh output long is appended holding the
high bits (`code >> -bitspace`), then the remaining
`code << bitspace` is ORed into it.  Cursor `a0` points at the
pending long; output is counted in whole longs.

## Adaptive reset

Every 1024 input bytes (`checkpoint`) the packer compares the
bytes emitted in the last window (`delta`) against the previous
window (`thresh`).  If `delta >= thresh + 128` compression is
degrading: `thresh = 0xfffff`, `T_pref` is wiped, `T_code` from
index 128, `nextcode = 0x104`, code 0x101 is emitted, and
width/maxcode restart at 9/0x1ff.  Verified live on a
compressible->medium-entropy stream (reset marker observed in
the code stream, decoder recovers).

## Error paths

- `AllocMem` fail -> -7.
- Output cursor reaching `outbuf+inlen` -> -17 (packed data must
  stay smaller than the input; XPK then falls back to storing).
- `xsp_Password` is dereferenced unconditionally (`tst.l (a1)`):
  a NULL password pointer would crash.  The XPK master always
  passes a string, so it is latent.

Verification: encoder output is **byte-identical** to an
independent Python model written from the disassembly on text,
README-size, 120 KB reset-triggering, and password inputs
across modes 0/34/100.
