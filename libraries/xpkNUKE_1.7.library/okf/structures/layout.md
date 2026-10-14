# xpkNUKE 1.7 — structures

## Hunks

```
hunk0 CODE — stub (-1 return) + RomTag + functab + all code
hunk1 DATA — XpkMode/XpkInfo descriptor structs
```

## Functab

code+0x2e: 8 absolute longs + `-1` terminator (long-absolute format —
no 0xffff word marker).

## XpkSubParams (caller's param block)

```
+0  APTR  xsp_InBuf
+4  ULONG xsp_InLen
+8  APTR  xsp_OutBuf
+12 ULONG xsp_OutBufLen
+16 ..    workspace / userdata fields (see source struct defn)
```

## Pack workspace (3 AllocMems per PackChunk)

- 92B cleared header/state block
- 0x20000 hash/tab1 (memset each call — NOT cleared by AllocMem flag)
- 0x10000 tab2 (ditto)
