# recent.library — data structures & hunk layout

## On-disk file format (`ENVARC:Recent/<name>`)

```
offset  size  field
0       4     magic 'RCNT'
4       ...   repeated group records, until EOF:
              +0   4   group key (compared verbatim vs d1/d0 key args)
              +4   1   maxcount  (sub-block capacity in records)
              +5   1   used      (records present)
              +6   ... `used` records:
                       +0   1        namelen (includes NUL)
                       +1   namelen   full document path string
                       +1+namelen 12 payload bytes (a dos.library
                                    DateStamp: days/mins/ticks)
```

`_load` reads magic, then loops `Read(4)` -> key / `Read(1)` -> max /
`Read(1)` -> used, allocating `0x14 + max*0x14` per group. `_save`
writes the identical layout (keys at sub+4, counts at sub+9/+0xa).

## In-memory structures

### Group header block (blk, 12 bytes, per `_load(a1)` slot)

| off | field |
|-----|-------|
| +0  | name copy (AllocVec strlen(name)+1) |
| +4  | full data-path buffer `"ENVARC:Recent/"+name` (strlen+0xe) |
| +8  | sub-block list head (linked via each sub-block's `[0]`) |

### Sub-block (one key, 0x14-byte header + `max*0x14` record array)

| off    | field |
|--------|-------|
| +0     | next sub-block |
| +4     | key (4B, compared against d0/d1 args) |
| +8     | maxcount (capacity) |
| +9     | effective max (`_setmax` shrink target; initialised = maxcount) |
| +0xa   | used count |
| +0xb   | scratch byte (namelen during `_save`) |
| +0xc   | gadtools `struct Menu *` built by `_menu` |
| +0x10  | NewMenu array buffer (own size prefix at buf+0) |
| +0x14  | `used` records, 20 bytes each |

### Record (20 bytes)

| off    | field |
|--------|-------|
| +0     | basename pointer (into `+4` string, after last `/` or `:`) |
| +4     | full path string (individually AllocVec'd) |
| +8..19 | 12-byte payload — dos DateStamp {days, mins, ticks} |

## Hunk / InitTable layout (h0)

```
0x00  _stub: moveq #0,d0 / rts        (hunk entry, never a vector)
0x04  RomTag: 4afc | endskip=0x74 | flags 0x80 | ver 0 | type 0x09
      name -> 0x1e  "recent.library"
      idstr -> 0x2d "recent.library 0.9 (September 20, 1999)"
0x55  "dos.library" / 0x62 "gadtools.library" (dep names)
0x74  InitTable: dsize=0x34, ftab->0x84, dtab->0xbc, initfn->0xdc
0x84  functab: 13 absolute longs + 0xffffffff
0xbc  datatab: InitStruct words (name->0xa, ver 0/rev 9, idstr->0x18)
0xdc  initfn: OpenLibrary(dos,33)+OpenLibrary(gadtools,36) ->
      lib+0x26 / lib+0x2a; Alert on failure
0xb0c "ENVARC:Recent/" (14B)
0xb1a 'RCNT' magic (4B) + pad -> 0xb20 hunk end
```

## Relocations

24 self-references, all to hunk 0. The original producer writes the
RELOC32 groups in `{count=24, hunk=0, offsets...}` order (count before
hunk index — nonstandard field order preserved by `fixup.py`).
