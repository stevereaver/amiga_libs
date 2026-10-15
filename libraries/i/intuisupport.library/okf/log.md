# intuisupport.library -- work log

- Parsed HUNK structure: two hunks, CODE 1772B + DATA 128B,
  relocs 21 (hunk0 self + hunk1 targets) / 4 (code->DATA refs:
  rt_Init and two lea template pointers + vestigial +0x17e).
- Identified the module as a manual-init library built by a code
  generator: RomTag rt_Init -> DATA+4 (inittab in data hunk with
  raw code offsets), init routine at code+0x24 builds the Library
  node itself, copies DATA hunk to base+46, fixup loop (count 0).
- Musashi oracle: correct hunk reloc semantics make init run --
  opens intuition.library + graphics.library (data+88/+106),
  stores bases at priv+124/+128.
- Decoded all 15 vector slots; 11 exported functions identified:
  Make3DBorder / FreeBorder (raised Border pairs), AllocBufList /
  FreeBufList / ResetBufList (36B double-buffer object),
  FillBuf / ClrBuf / StrLen / ISCopyMem helpers, AbortAlert
  (DisplayAlert + caller callback, German abort message),
  DrawText (SetAPen/SetBPen/Move/Text via obj+50 rastport).
- Traced AbortAlert buffer bytes empirically; confirmed caller
  text is never copied (zeroed hole) and buf[3] = *callback.
- C reconstruction + register-ABI vector stubs; built HUNK
  library; Musashi A/B run against the original: identical init,
  open sequence, vector semantics, border list bytes, buflist
  header, alert string bytes, drawtext call sequence.
- Plane: AMIGALIBS-99.
