# easylife.library 1.02 — layout

## Library (dsize 0xfc)
- +32.w opencnt; +14 flags (LIBF_DELEXP bit3); +34 SysBase; +38 seglist
- +42 user allocator hook ptr (NEVER initialized by datatab — caller must install)
- +236 hook arg (a0) for the +42 hook
- +240 pool head (lazy); +244 elt count; +248 chunk chain head

## Pool chunk (built by _f2f6, size = poolhead+12)
- +0: block base; +2: data start (base+24); +6: free head; +10: end
- +14: usable size (size-32); +18: next-chunk link; +24+: elements

## Sub-table at pool+d0 (searched by _f1d8)
- +0.w count; then count longs: hi16 = byte index into pool, lo16 = key

## Element descriptor (at pool + index)
- +0.b jump-table selector, +1.b ndims
- +2: ndims x word (per-dimension index)
- then long offset (added to caller a1 array base for GET/SET)

## a5 context (file I/O vectors only)
- caller passes a5 = context block; a5@(696) = dos.library base.
  Calling -90/-96 with a5 != context reads wild memory (quirk).

## File format
- 'ElSt' magic, count, then per-entry records
