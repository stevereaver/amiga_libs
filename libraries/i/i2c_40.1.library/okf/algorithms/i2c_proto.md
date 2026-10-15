# i2c.library 40.1 — PFC8584 protocol

`ctrl_init` (LAB_0051) — runs before every transfer:

```
regs[2] = 0x80          ; S1' reset: select own-address reg
regs[0] = 0x55          ; own address = 0x55
regs[2] = 0xa0          ; select clock reg
regs[0] = clk[min(delay,3)]   ; prescaler row byte
regs[2] = 0xc1          ; enable + PIN
```

delay = base+0x44 clamped unsigned <=3; clk[4] = one of
{0x00010203, 0x10111213, 0x14151617, 0x18191a1b, 0x1c1d1e1f}
for crystal 3/4/6/8/(other→20) MHz.

## Write (-54)

sem -> stat_wrc++ -> if !present: stat_nopres++, err=8 -> out
(ctrl_init) -> addr&=~1 -> regs[0]=addr -> regs[2]=0xc5 (start)
loop:
  timeout=25; poll st=regs[2] while st&0x80 (BB), !timeout -> err 6
  st&0x10 -> err 3 (arbitration lost)
  st&0x08 (LRB no-ack):
     len==orig -> err 2 + stat_noreply++ (address NAK)
     len==0    -> err 0 (trailing NAK swallowed!)
     else      -> err 1 + stat_rej++
  else --len <0 -> done; regs[0]=*buf++; stat_wrb++
done: regs[2]=0xc3; wait (timeout|regs[2]&1) ; pack; relsem

## Read (-60)

Same, addr|=1. After start-poll: len<=1 -> regs[2]=0x40 (NAK mode);
dummy `tst.b (regs)` primes receiver.
loop: poll; --len; len==1 -> 0x40; len<=0 -> 0xc3; st=regs[0];
      len<0 -> done; *buf++=st; stat_rdb++; len!=0 -> loop.

## Timeout

base+0x8c armed to 25 before each poll; I2CIntr (int 5 / VERTB,
is_Data=base via a1) decrements while nonzero — ~0.5 s at 50 Hz.
Timeout -> err 6 + stat_err++.

## I2CErrText (-72)

Index: state(1..6) -> 9..14; else err(1..8) -> 1..8; else ok!=0 -> 0
("OK"), ok==0 -> 15; out-of-range -> 16. Table -> string via
SIGN-EXTENDED byte offset (see defects.md — bug makes 7 entries point
into the functab).
