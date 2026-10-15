# xpkHFMN 1.36 (020+) — defects & quirks

All preserved faithfully in the reconstruction.

## 1. Pack histogram reads 64 KiB on inlen == 0

The histogram counter is a 16-bit DBF on `inlen - 1`: `inlen == 0`
wraps to 65535, so the packer reads 65536 bytes from the input buffer
and builds a tree over garbage. Emits a stream for "65536 input bytes".
Same defect exists in V1.4. Reproduced in host test (`empty pack ->
0 outlen=8203`).

## 2. Pack has no mid-emit output bound

Unlike V1.4 (which checks `out+inlen` inside the emit loop), 1.36
writes the tree and all code bits unbounded — overrun scribbles past
`OutBuf` — and only afterwards returns `-17` when
`OutLen > OutBufLen`. On a real system that writes past the caller's
buffer before admitting failure. Faithfully modelled (the emit loop
has no bound check).

## 3. Pack bound changed semantics vs 1.4

1.4: `a4 = out + inlen` — the pack *succeeds only if the packed form
is strictly smaller than the input*.
1.36: bound is `xsp_OutBufLen` — packing "succeeds" even when the
output is larger than the input (e.g. random 4 KiB -> 4414 bytes,
accepted). Callers relying on "packed < original" semantics get
surprised. Not a crash bug; a contract change.

## 4. Unpacker trusts the stream completely

No bound checks anywhere: the tree-size word (`& 0x1ff`), the leaf
bit pattern, code lengths >16 bits (deep-path trie), and the 32-bit
window walk all index freely. A corrupt/malicious stream walks the
trie off the end and reads/writes outside the work and output
buffers. Same in 1.4; preserved.

## 5. Unpack work area is a code-generation buffer (self-modifying code)

The decoder *writes m68k machine code* into the AllocMem'd area at
+0x13fa and `jsr`s into it — interior Huffman nodes become
`add.l d0,d0; bcc target`, leaves become `moveq #sym,d1;
move.b d1,(a2)+; dbf loop`. Requires the CacheClearU icache flush on
68030+. Consequences:

- cannot run from a write-protected or ROM image,
- unsafe on systems where AllocMem'd memory is non-executable
  (emulators with strict MMU, some 68060 configs),
- the generated code is keyed to exact output positions; a hostile
  tree can emit jumps outside the buffer (decoder OOB anyway per #4).

The C reconstruction models the *semantics* (trie + 10-bit fast
table + deep walk) rather than emitting opcodes — that generated-code
mechanism is itself the quirky part worth documenting.

## 6. Version/exec gate only on the unpack side, partially

Pack gates on AFB_68020 (correct for bfins/bfextu/scaled-index).
Unpack's exec V36 check only fires when AFB_68030 is *also* set —
on a stock 68020 the generated code runs without CacheClearU, which
is correct for '020/'010 (no separate icache concerns vs. 030+), but
a 68020 accelerator board with an 030+ kernel patching AttnFlags
could hit the -21 path inconsistently. Edge quirk, faithfully kept.

## 7. Heap sift / tie-break ordering (not a bug, but locked behaviour)

The 1-based min-heap sift uses `BLS` (break on strictly-less) +
right-child preference on ties — the same ordering as 1.4, which is
what makes 1.36's emitted streams byte-identical to 1.4's on every
tested input. Any "cleanup" here silently changes the stream.
