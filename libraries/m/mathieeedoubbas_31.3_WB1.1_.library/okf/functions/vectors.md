# mathieeedoubbas 31.3 — vectors

Public convention (as built by the hunk1 wrappers): doubles in
`d0:d1` (+ `d2:d3` second operand); results in `d0:d1` or `d0`.
Internally all arithmetic is done in memory through three scratch cells
inside hunk1 (`_scr0/_scr1/_scr2`).

| LVO | vector      | in             | out    | notes                                  |
|-----|-------------|----------------|--------|----------------------------------------|
| -6  | Open        | a6=lib         | d0=lib | opencnt++                              |
| -12 | Close       | a6=lib         | d0     | opencnt--; at 0 with LIBF_DELEXP -> expunge |
| -18 | Expunge     | a6=lib         | d0     | open: sets DELEXP, ret 0; else Remove+FreeMem, ret seglist |
| -24 | Null        |                | d0=0   |                                        |
| -30 | IEEEDPFix   | d0:d1 double   | d0 int | trunc toward 0; overflow -> garbage (see quirks) |
| -36 | IEEEDPFlt   | d0 int         | d0:d1  | exact, incl. INT_MIN                   |
| -42 | IEEEDPCmp   | d0:d1, d2:d3   | d0     | -1/0/+1                                |
| -48 | IEEEDPTst   | d0:d1          | d0     | -1/0/+1; -0.0 -> 0                     |
| -54 | IEEEDPAbs   | d0:d1          | d0:d1  |                                        |
| -60 | IEEEDPNeg   | d0:d1          | d0:d1  | neg(-0.0) -> -0.0                      |
| -66 | IEEEDPAdd   | d0:d1, d2:d3   | d0:d1  |                                        |
| -72 | IEEEDPSub   | d0:d1, d2:d3   | d0:d1  |                                        |
| -78 | IEEEDPMul   | d0:d1, d2:d3   | d0:d1  |                                        |
| -84 | IEEEDPDiv   | d0:d1, d2:d3   | d0:d1  |                                        |

## Observed edge behaviour (original, machine68k)

```
fix(42.9)=42  fix(-42.9)=-42  fix(1e300)=0x0000006b (overflow)
flt(42)=42.0  flt(-42)=-42.0  flt(INT_MIN)=-2147483648.0
cmp/tst sign convention -1/0/+1 ; tst(-0.0)=0
abs(-3.25)=3.25 ; neg(3.25)=-3.25 ; neg(-0.0)=-0.0
add(1.5,2.25)=3.75  add(5e-324,5e-324)=1ulp (subnormal add works)
sub(1.5,2.25)=-0.75
mul(1.5,4)=6  mul(1e200,1e200)=0x7fffffffffffffff (NOT ieee inf)
mul(5e-324,2)=+0.0 (subnormal mantissa lost)
div(7,2)=3.5  div(1,3)=0x3fd5555555555555  div(1,0)=0x7fffffffffffffff
```

`expunge` while open sets `lib_Flags=0x0e` (DELEXP bit set on 0x06 base);
the following `close` performs the expunge and returns the seglist.
