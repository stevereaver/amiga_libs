# xpkBLZW 3.4 — Quirks & defects (reproduced)

1. **Emit-bound reads the wrong frame slot.** The special-code emit
   subroutine (orig 0x2ca) bounds the output cursor against `sp@(8)`
   — the *checkpoint input cursor* — instead of `sp@(4)`, the real
   limit used by the inline emit.  Before the first ratio checkpoint
   that slot holds uninitialised stack garbage, so every 258 emitted
   while the dictionary is still growing (all bumps, for maxw<15…
   every 258, since checkpoint only inits once width==maxw) is
   bounded by garbage.  In practice the garbage is a large pointer
   and the check passes; a small stale value would make pack return
   -17 nondeterministically.  Reconstruction models the field as
   `chk_in`, initialised to "never fires".

2. **Output pre-clear underflows for inlen < 32.** The backward
   `moveml` sweep that zeroes `out[0..inlen&~31)` runs `inlen>>5`
   times via a `swap`-doubled dbf; for inlen < 32 the counter
   underflows to ~2M iterations and scribbles ~64 MB below the
   output buffer (heap corruption / crash on real hardware).  The C
   reconstruction clears the same region for inlen >= 32 and clears
   nothing for inlen < 32 — pack then returns -17 as soon as the
   bound (out-8) is crossed, matching the original's effective
   behaviour for such inputs.

3. **Width can lag dictionary growth.** The 258 bump fires once per
   emit when `next >= thresh && prefix >= thresh`.  If the table has
   raced far past a threshold without any emitted code >= thresh
   (possible with long low-code matches), a single +1 bump still
   emits a prefix >= 2^new_width — the top bits are silently lost.
   Rare in practice; reproduced verbatim.

4. **`moveaw` sign-extends maxlen.** The decoder reads the stream's
   maxlen word through `moveaw a0@,a0`, so maxlen >= 0x8000 would
   sign-extend into the allocation size.  The packer only ever
   writes `maxdepth & ~3`, so well-formed streams are unaffected.

5. **OOB reads/writes on edge cases are unguarded**, matching the
   original: pack reads `in[0]` before checking inlen; the decoder's
   string stack has no underflow check on corrupt streams; a
   code > nextfree takes the KwKwK branch (decodes garbage rather
   than erroring).

6. **OutLen write races restored registers** (benign): the original
   computes `a1-out` into d0, *restores* a0 to the param block, then
   stores d0 at `a0@(16)` — a cute but correct use of the restored
   register.

7. **`rt_EndSkip = 0`** (literal, not relocated) and the datatab's
   `lib_Flags = 6` are reproduced verbatim.
