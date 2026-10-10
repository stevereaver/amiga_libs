# log

- **RE session**: single CODE hunk (HUNK_CODE@0x14, size 0x14d longs, data@0x20). The IRA .cnf declared MACHINE 68000 so all `f2xx` opcodes were left as DC.W — they are 68881 FPU instructions (`fmoves`/`faddx`/`fdivx`/`fmulx`/`fmovel`/`fcmps`/`fblt`).

- LibInit @0x100: `btst #1,297(a1)` (AFB_68020) and `btst #4,297(a1)` (AFB_68881), fails with 0 if absent; stores seglist@34.
- Codec: encoder @0x17e, decoder @0x292, model update @0x352, model init @0x3b4, workmem alloc @0x274 (`swap`-ed `moveq #32` = 0x200000), free @0x266.
- Model: freq table 2×float/state at base+0, link table 2×long/state at base+0x100000. States 0..0xfffe static (256 rows × 255 nodes: inner c<127 → {a2+2c+1,a2+2c+2}, leaf c≥127 → {(c+1)<<8,(c-127)<<8}); clone slots 0x10000..0x1fffe.
- Round-trip host-tested: 3866 cases, 0 fails, 134 -17 rejects (output bound = inlen+40).
