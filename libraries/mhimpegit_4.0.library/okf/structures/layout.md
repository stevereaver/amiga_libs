# mhimpegit.library 4.0 — memory layout

## Hunks (file order)

| # | Type | File bytes | Notes |
|---|------|-----------:|---|
| 0 | CODE | 1692 | code+0 = `moveq #-1,d0;rts`; code+4 LibInit; RomTag @0x140; datatab @0x15e; strings + vectors |
| 1 | DATA | 84 | +0 `0x00dff000` (dead const), +4 InitTable, +0x14 functab (14 longs), +0x50 `0x00dff000` |
| 2 | BSS  | — (16) | globals: lib, exec, dos, prelude |

InitTable at data+4: `{dataSize=0x2e, funcTable→data+0x14,
initData→code+0x15e, initRoutine→code+4}`.

datatab at code+0x15e (InitStruct cmds):
```
e000 0008 0900        INITBYTE +8  = 9      (ln_Type = NT_LIBRARY)
80 0a <name>          LONG     +10 = name   (compact form)
e000 000e 0600        INITBYTE +14 = 6      (flags byte)
d000 0014 0004        INITWORD +20 = 4      (version)
d000 0016 0000        INITWORD +22 = 0      (revision)
80 18 <idstr>         LONG     +24 = idstr
00 00                 end
```

## Library base (dataSize 0x2e)

| off | field |
|----:|---|
| +32 | OpenCnt (UWORD) |
| +34 | seglist (private) |
| +38 | ExecBase (private) |
| +42 | DOSBase (private) |

## BSS (16 bytes)

| off | contents |
|----:|---|
| +0 | library base |
| +4 | ExecBase (write-only shadow; code re-reads absolute 4) |
| +8 | DOSBase |
| +12 | PreludeBase |

## Create object (18 bytes, AllocVec CLEAR)

| off | field |
|----:|---|
| +0 | tag0 value (Create a0 arg) |
| +4 | tag1 value (Create d0 arg) |
| +8 | → list block (12B MinList header, separate AllocVec PUBLIC|CLEAR) |
| +12 | node count |
| +16 | unused/zero |

## Node (18 bytes, AllocVec PUBLIC|CLEAR)

| off | field |
|----:|---|
| +0 | ln_Succ — chain via `a2 = *a2` |
| +4 | ln_Pred (list) / tail ptr |
| +8 | data0 (Append a0 arg) — returned by Pop, passed to prelude@-60 |
| +12 | data1 (Append d0 arg) — passed to prelude@-60 in d0 |
| +16 | word flag: 0=pending, 1=notified |

## prelude.library internals referenced

| expr | meaning |
|---|---|
| `*(prelude+0x38)+0x15` bit0 | feature gate checked by Create |
| `*(prelude+0x8e)+0x10` ULONG | flag/depth: gate for Pop (>=count blocks), trigger for Append's immediate notify, cleared by Create/Drain |

## External calls

- Exec: OpenLibrary -552, CloseLibrary -414, Remove -252, RemHead -258,
  AddTail -246, FreeMem -210, AllocVec -684, FreeVec -690.
- DOS (BSS+8): Delay -198.
- prelude (BSS+12): -36, -60, -84, -90.
