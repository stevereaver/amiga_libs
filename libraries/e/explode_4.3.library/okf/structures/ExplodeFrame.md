# ExplodeFrame - 0x44 bytes on the stack (A4)

| Off | Field | Role |
|-----|-------|------|
| +0  | litcount | literals remaining in current run |
| +2  | bitbuf | bit reservoir (MSB-first, sentinel refill) |
| +3  | pending | match length remaining when ring drained |
| +4  | blocks | block count; sign flag adjusts range build |
| +8  | tbl[12] | len_base[0..7] + len_bits[0..7] (overlapped) |
| +20 | range[8] | 1<<bits per distance class (-1 if blocks<0) |
| +28 | cum[4] | range[4..7] += range[0..3] - far-match bases |
| +36 | offbits[12] | per-format distance bit counts |
| +52 | chain | hunk node table base (= stream - 32) |
| +56 | nsegs | chain link count - 1 |
| +58 | oldpri | saved task priority |
| +60 | task | FindTask(NULL) |
| +64 | outcount | bytes copied out (feeds ctr2) |

Quirk: stream byte0 high nibble is stored at +19 (= tbl[11]) -
it OVERRIDES the last len_bits entry, an encoder-chosen tweak.
