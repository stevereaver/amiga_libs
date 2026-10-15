# GRCall6 (LVO -42)

Looks up launcher table key 6.  On failure (no port, table key
missing) returns -2.  Otherwise:

```
Disable
GRSupervisor: if AFF_68010 -> Supervisor(movec d4,vbr)
res = fn6(arg)          ; arg in a0
CacheClearU
Enable
return res              ; handler's d0
```

The `movec d4,vbr` writes whatever the caller left in d4 into
the VBR -- see findings/VBRQuirk.md.
