# AFBase -- library base layout (dataSize 0x30)

| off | field | notes |
|-----|-------|-------|
| 0x00 | `struct Library` | filled by InitStruct stream |
| 0x22 | unused longword | reserved |
| 0x24 | `SysBase` | stored by LibInit |
| 0x28 | `DOSBase` | `OpenLibrary("dos.library",0)` at init |
| 0x2c | `SegList` | from initfn a0 |

## InitStruct stream (datatab)

```
a0080900   INITBYTE ln_Type  <- 9 (NT_LIBRARY)
800a<ptr>  INITLONG ln_Name  <- "amigaflight.library"
a00e0600   INITBYTE lib_Flags <- 6
90140001   INITWORD lib_Version = 1
90160002   INITWORD lib_Revision = 2
8018<ptr>  INITLONG lib_IdString <- idstr
0000       terminator
```

## Call ABI

- `a1` = dos filehandle on every public vector (console handle).
- `d0` = value arg/result, `d2` = string pointer for -102.
- `a6` = library base (standard LVO dispatch).
- a6+0x28 dereferenced directly by I/O vectors -- if LibInit's
  OpenLibrary failed, every vector crashes via a NULL dos base.
