# findings / defects

- **Unreachable clones**: the clone routine links the *clone* self on
  the chosen bit and to the target's other child, but never re-points
  `link[ctx][bit]` (nor `link[tgt][bit]`) at the clone -- cloned states
  are **never entered**. Their freq mass is real (target loses it
  permanently) so hot transitions decay, and `m_free` still burns
  slots until 0x1ffff triggers a full model reset. Reproduced
  verbatim; behaves like aggressive count-aging.
- **Bound check after emit**: the encoder writes the renorm byte,
  *then* checks `out >= bound` -- one byte can be stored past
  `dst+inlen+40` before the -17 abort.
- **No decoder bounds**: the decoder trusts the stream length and
  reads src freely; corrupt input walks off the buffer.
- **FPU hard requirement**: refuses to init without 68020+68881 --
  the only XPK sublib in the set with a CPU gate.
- **Header quirk**: the hunk header "last hunk" field contains the
  hunk size (0x14d) rather than the index; harmless to loaders that
  only use tablesize.
