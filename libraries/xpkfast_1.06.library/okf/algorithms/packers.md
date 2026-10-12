# xpkFAST 1.06 packers

Two packers, mode < 80 -> speedy, mode >= 80 -> crawling
(unsigned compare — negative modes crawl).  Both write the same
stream: literals forward at `o`, ctrl/token words backward at
`cw` from `ctop`.

## Speedy (code+0x314)

- Workmem 0x10000 = one ULONG table of **16384** entries,
  pre-filled with `in_end` (the "empty" marker — a candidate
  whose distance is 0 for any src, so `dist < 0x1000` fails
  only... no: `src - in_end` is negative -> unsigned huge ->
  rejected; see the hash note below).
- Hash, stateful on `d1` (bits 8..15 persist between tokens):
  ```
  h = (h & 0xff00) | b0
  h = (h << 3) & 0xffff
  h = (h & 0xff00) | ((h + b1) & 0xff)
  h = (h << 3) & 0xffff
  h = (h & 0xff00) | ((h + b2) & 0xff)
  h = (h << 2) & 0xffff        -> index h>>2
  ```
- `cand = tab[h]; tab[h] = src`; reject if `(ULONG)(src-cand)
  >= 0x1000` — unsigned, so stale/empty candidates are
  rejected cleanly (unlike 1.2's signed test).
- Greedy single candidate; compare up to 18 bytes; len < 3 ->
  literal else match.
- **Two phases**: the head loop checks the input bound only
  when a 16-item flag word completes; when `src >= in_end-288`
  the "tail" phase takes over with a per-item bound check.
  The last words of input are hashed/matched with bytes read
  past `in_end` (harmless — bounded by the tail check).

## Crawling (code+0x534)

- Workmem 0x44000:
  - hash table u32[65536] at `work+0` — reached through the
    negative-biased long index `(0xffff0000|gram)<<2` onto base
    `work+0x40000` (the `0xfffc0000` offsets wrap modulo 2^32
    and land at `work+0..0x3fffc`).  Bytes
    `work+0x10000..0x40000` are **dead space** — pure waste,
    only the first 64 KB of the hash range are addressable.
  - chain table u32[4096] at `work+0x40000`, indexed by
    `pos & 0xfff`.
  - the first `0x11000` longwords (both tables) are filled with
    `in-4096` — a candidate below the window floor, i.e. "empty".
- Gram hash: `g = (b0<<8) | ((b1+b2) & 0xff)` — the second byte
  is the SUM of bytes 1..2 folded into the low byte.
- Positions are stored as the gram's END pointer (`in+2` for the
  primed gram; `a0+1` per literal insert).
- Chain walk (`d5` = candidate): stop when `d5 < floor`
  (`floor = a0 - 4095`).  Compare loop runs up to 16 `cmpm`
  steps starting at the gram's **third** byte position and
  extending forward; `lf` counts the executed compares
  INCLUDING the failed one, so `lf = equal+1`, and the wire
  length field is `lf` (decoded length `= lf+1 >= 3`; a 16/16
  run yields lf=17 -> len 18).
- **Stale-candidate re-evaluation**: after a match, `d5` still
  holds the last rehashed gram's previous head.  The shared
  eval point re-walks from that stale head — this is why the
  original can emit back-to-back matches with no literal
  between them (observed on "abc...abc" inputs).
- `best` rides as `(dist<<16)|lf`; token =
  `(dist<<4) | (17 - lf)`.
- **Literal path emits `a0[-2]`** — the byte BEFORE the gram,
  not the gram head: the cursor semantic is "points at the
  gram's last byte".

## Emit / drain

- Literal: byte -> `o`, flag 0 shifted in.
- Match: token -> `cw -= 2`, flag 1 shifted in; `floor` advances
  by `lf+1`; `lf+1` grams are rehashed/inserted.
- Flag-word completion stores at the reserved `slot`, reserves a
  fresh `cw` slot, reseeds the register.
- On `a0 >= in_end2` (`in+inlen+2`): drain — rotate the
  register until the sentinel pops; the first injected bit is
  **X = 1 left by the last `asl.l`** (a `1`, not a `0` pad bit).
  Then `pk_finish`.
- The literal loop's end-check only runs at flag-word
  boundaries and uses `in_end+2` — the original reads/emits
  bytes past the input end (defect #3).
