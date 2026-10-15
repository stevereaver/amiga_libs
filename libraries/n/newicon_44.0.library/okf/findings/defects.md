# newicon_44.0 — quirks & defects

Reproduced faithfully in `source/newicon.c`.

1. **AddFreeList size = allocation pointer.** In the
   tracked-alloc helper the `AddFreeList(fl, mem, size, ...)`
   call passes the *just-returned block pointer* as the size
   argument (d0/d2 not reloaded after AllocMem).  The
   freelist entries are therefore created with a bogus,
   huge "size".  Harmless in practice (freelist only walks
   the list to free it) but strictly a defect.

2. **No DEFAULTIMAGE recursion guard.**  An icon whose
   DEFAULTIMAGE tooltype resolves to a non-palette-mapped
   icon (or itself) recurses in `xget` until the stack is
   exhausted.

3. **`bfexts` sign-extension drives transparency.**  The
   transparent-pen set tags are computed as
   `~sext(flag&1)` = `flag&1 ? 0 : -1` — i.e. pen **0**
   becomes transparent after the palette-0↔pen swap.  A
   naive `~flag&1` read gives the wrong polarity.

4. **Inverted default-type tag.**  `xget` emits
   `TAG_IGNORE` for the GetDefaultType slot when `name` is
   non-NULL, and `GetDefaultType=dtype` when `name` IS NULL
   (the `beq` skips `moveq #TAG_IGNORE`).  Semantically
   correct, but backwards vs a casual read.

5. **`remap` dead code & impossible compare.**  The `bcs`
   after `addal #-256` is unreachable (C is always set by
   the 1-byte `subb`), and the "pixel == transparent pen"
   test compares `0xffffff00|px` against a word-size pen so
   it can never fire for positive pens.

6. **Open's program-name check accepts prefixes.**  The
   string compare is `stri()` (bounded prefix compare), so
   "newiconsX" callers are also refused — and with an empty
   FilePart every caller is refused (n==0 case).

7. **tstl a0 idiom.**  The original tests pointers with
   `tstl aN` — non-portable but functional; the
   reconstruction uses `movel aN,d0; tstl` equivalents.

8. **DONE-pair data left uninitialized.**  Taglists push
   `clrl` for the terminator tag only; the adjacent data
   long is stack residue (observed values ~0x3000xx).
