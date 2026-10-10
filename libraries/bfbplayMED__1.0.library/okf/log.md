# Work log — bfbplayMED!.library V1.0

1. Single CODE hunk, packed RomTag AUTOINIT, dataSize 0xb2.
2. functab LONGs at +0xcc: 14 vectors; LibInit opens dos.library only.
3. InitModule decodes as tag-driven loader: tag scanner at +0x53e,
   source triple filename/handle/memory + required session tag.
4. File path: Seek(h,0,OFFSET_END) then Seek(h,0,OFFSET_BEGINNING) —
   second return value = previous position = file size.
5. Session block is 80B MEMF_PUBLIC (not cleared) with UNALIGNED
   longs at +2/+10/+26 — needs 68020+ host CPU semantics.
6. medplayer vectors -30/-36/-42/-48/-54/-96/-102 mapped by usage.
7. Dead 31-long trailer after hunk end documented.
8. Reconstruction: C + asm skeleton; datatab byte-identical;
   shipped defects preserved (stray ti_Data store, uninit sess
   on early-error unwind, uninit maxvol clamp, medplayer double
   close in Expunge).
