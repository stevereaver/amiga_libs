# epu1.library — structures

## EpuCtx (58 bytes, MEMF_CLEAR)

| off | field | source |
|-----|-------|--------|
| +0  | src   | caller a0 |
| +4  | dst   | caller d1 |
| +8  | slen  | caller d0 |
| +12 | bound | caller a1 |
| +16 | name  | caller a2 (used in OOM dialog) |
| +20 | blk   | lh control block from lh -30 |
| +24 | res   | lh result |
| +28 | ...   | unused tail to byte 57 |

## lh control block (written by epu)

- pack:   `{src, slen, dst}` (blk[3] left as lh -30 initialised it)
- unpack: `{src, slen, dst, bound}`

## IntuiText records (data hunk, 20 bytes each)

`{0,1,1,0, L=5, T=23|13|3, font=0, text, next}` for the body,
`{0,1,1,0, L=6, T=3, font=0, "RETRY"/"CANCEL", next=0}` for the gadgets.
AutoRequest(window=0, body=chain, pos, neg, 0,0, width=310, height=68).
