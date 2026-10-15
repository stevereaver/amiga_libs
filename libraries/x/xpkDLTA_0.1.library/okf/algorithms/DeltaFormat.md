---
type: Algorithm
title: DeltaFormat
description: Size-preserving byte-delta coding.
---

# DELTA transform

Size-preserving; the packed stream is the same length
as the input:

    fresh chunk:    out[0] = in[0]
                    out[i] = in[i] - in[i-1]   (mod 256)
    decode:         out[0] = in[0]
                    out[i] = out[i-1] + in[i]  (mod 256)

Cross-chunk chaining: when the caller sets xsp_Sub[0]
nonzero, byte 0 is treated as a delta continuing from
xsp_Sub[1] (the running value from the previous chunk);
both codecs write the final state back to xsp_Sub[1].

"Encryption" naming is marketing — delta coding is a
preconditioner (helps LZ/RLE on smoothly-varying data),
not a cipher.

Dead-code kernels at the hunk tail implement the same
transform at 16- and 32-bit widths (ByteMode suggests a
planned mode selector that was never wired up).
