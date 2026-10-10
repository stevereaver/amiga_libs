# I2C transfer engine

Registers: `$de0080` ctrl (w: bit0 SDA out, bit1 SCL), `$de0081` bit0 SDA in,
`$bfd000` CIAA PRA reads for timing.

- **Delay units:** base+68 (env `I2CDELAY`, default 0). Waits:
  edge  = (d5+1)*2 reads (clamped >=1); in-shifter waits are
  d5>>1, (d5+1)>>1, d5 — each clamped to >=1.
- **START:** ctl bit0=0 (SDA lo, SCL hi), wait, bit1=0 (SCL lo), wait.
- **Byte clock (9 bits):** for bit=8..0: SDA = rotated-tx bit;
  SCL hi; sample SDA into rx bit; SCL lo. Sends tx bits 7..0 then
  bit15 (the "flag" bit held at 1 = release during ACK slot).
- **STOP:** SDA lo, wait, SCL hi, wait, SDA hi, wait.

## Send (-54)

`d0 &= ~1; d0 |= 0x8000` (W + flag), START, clock address;
echo byte must equal sent byte (`subb`), else err 3/4/5.
Bit15 of rx = NACK: if no data sent -> err2, else err1/partial.
Each data byte clocked with bit15 forced 1 (release on ACK).

## Receive (-60)

`d0 |= 0x8001` (R + flag). Address NACK -> err2. Per data byte
the master transmits 0x7fff (ACK, all-but-last) or 0xffff (NACK,
last byte); received byte stored to a1++ while count>0.
Count<=0 still clocks one byte but discards it (quirk).

## Result packing

`(laststat<<16) | (errcode<<8) | (errcode==0 ? 0xff : 0)`.
errcode 8 = board not claimed (skips STOP entirely).
