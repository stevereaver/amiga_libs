# XpksUnpackChunk (LVO -54)

Decoder for the RLEN stream.

## Algorithm

```
loop:
    code = (signed byte)*in++
    if (code == 0) break          # terminator
    if (code > 0)                 # literal run
        copy <code> bytes from in to out
    else                          # repeat run
        v = *in++
        write v to out, <-code> times
```

- `code` is sign-extended (`moveb` + `extw` + `extl`), so -128
  decodes as a 128-byte repeat.
- Returns 0.  `xsp_OutLen` is an **input** here (the caller's
  expected size) and is never written back — the same convention
  as v1.5.
- No bounds checking on either buffer: the stream is trusted.
