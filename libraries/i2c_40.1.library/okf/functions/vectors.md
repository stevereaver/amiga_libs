# i2c.library 40.1 — vector table

Absolute-pointer functab (DC.L x 14 + 0xffffffff terminator).

| LVO  | orig addr | name          | behavior |
|------|-----------|---------------|----------|
|  -6  | 0x214     | LibOpen       | OpenCnt++, dexp&=~8 (base+0x43 bit3!), probe, dead -48 call, ret base |
| -12  | 0x228     | LibClose      | I2CReset, d0=0, OpenCnt--, if 0 && dexp&8 -> Expunge (propagates seglist) |
| -18  | 0x240     | LibExpunge    | open: dexp|=8, ret 0. else RemIntServer(5,+150), RemNode, FreeMem(-NegSize, Neg+Pos), ret seglist |
| -24  | 0x210     | reserved      | moveq #0,d0 / rts |
| -30  | 0x288     | I2CProbe      | sem-locked detect; state: 0 ok / 1 board busy (cd_Driver) / 2 not found / 3 expansion missing (sticky!) / 5 shut down; sets present=0xff on success |
| -36  | 0x2e6     | I2CReset      | if OpenCnt==1: sdown=0, present=0; ret 0 |
| -42  | 0x306     | I2CDelay      | get/set delay index: ret old; if d0>=0 store (signed test!) |
| -48  | 0x2fa     | I2CReserved   | dead: TST.B present; BEQ (next insn); moveq #0,rts |
| -54  | 0x47c     | I2CWrite      | d0=addr a1=buf d1=len; stat_wrc++; polled PFC8584 write |
| -60  | 0x512     | I2CRead       | same regs; stat_rdc++; polled read w/ NAK-last-byte |
| -66  | 0x434     | reserved      | moveq #0,d0 / rts |
| -72  | 0x438     | I2CErrText    | packed result -> string (see defects: EXT.W bug) |
| -78  | 0x3f0     | I2CShutdown   | sem; sdown=0xff; present=0 (calls Reset tail); relsem; state=5 |
| -84  | 0x422     | I2CReEnable   | sdown=0; probe; dead -48 call; ret probe result |

## Result packing (I2CWrite/I2CRead)

`d0 = (state<<16) | (err<<8) | (err==0 ? 0xff : 0)` — byte0 is a success
flag, byte2 the i2c error, byte3 the board state *at entry* (stale).

I2C errors: 1 data rejected, 2 no reply (addr NAK), 3 arbitration lost
(protocol error), 6 timeout, 8 no controller present. Mid-transfer NAK
with len==0 is swallowed as success (err=0).
