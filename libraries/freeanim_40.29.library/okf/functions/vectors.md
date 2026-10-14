# freeanim.library 40.29 — vector map

4 vectors, all pointing at the same stub:

| LVO  | target | role |
|------|--------|------|
| -6   | 0x66   | Open  -> moveq #0,d0; rts |
| -12  | 0x66   | Close -> moveq #0,d0; rts |
| -18  | 0x66   | Expunge -> moveq #0,d0; rts |
| -24  | 0x66   | reserved -> moveq #0,d0; rts |

initfn is also the same stub: returns 0, so the library body is
inert — opens always return libbase? no: AUTOINIT initfn result 0
is still linked; Open returns d0=0, i.e. OpenLibrary callers get
failure. The lib exists solely to satisfy MakeLibrary scans /
version queries (id string carries the version).

No external library calls anywhere.
