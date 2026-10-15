# utility 41.0 (020) — RE log

1. Hunk parse: single CODE hunk (0x938), RomTag at +0
   (RTF_AUTOINIT|COLDSTART, ver 41, pri 103), InitTable at +0x1a
   {dsize=0x30, ftab->+0x2a, dtab=0, initfn->+0xd8}, word-offset
   functab (0xffff marker, offsets relative to marker), 49 entries
   -6..-294, NegSize 0x126.

2. Mapped all 49 vectors against NDK utility LVO list; disassembled
   every entry point.

3. Reconstruction: C implementations + asm skeleton (RomTag,
   InitTable, word-offset functab, 68020 patch stubs, patch table,
   software math, strings, tail object for rt_EndSkip coverage).

4. Hit Amiga-hunk linker bug: `.word symA-symB` functab differences
   referencing C symbols in another object misrelocated (all asm
   symbols correct, C targets off).  Fix: same-section `_vec_*`
   trampolines; `bras`/`jmp` short-relocs also overflowed, so the
   stubs use hand-encoded `.short 0x4ef9 / .long _Fn` absolute jmp —
   long relocs resolve correctly.

5. Oracle: emulates MakeLibrary (word-offset functab), AllocVec/
   FreeVec, semaphores, Enqueue/Remove/FindName (MinList tail
   sentinel), ReplyMsg, SetFunction, Permit, INTENA custom writes.
   Exercises init + all vectors and logs exec interactions.

6. Oracle-driven corrections vs first draft:
   - Pack/UnpackStructureTags is a longword-stream reader, not a
     pair reader (stale tag after first entry; -1 resyncs; bit29/30
     single-longword skip; `addaw` sign-extended offset).
   - FreeNamedObject computes block into a0 while FreeVec reads a1
     — frees caller's stale a1; moved the vector into asm.
   - CloneTagItems counts n+1 (in-bounds terminator, no overrun).
   - ANO_NameSpace is a boolean (->62-byte block); AllocNamedObjectA
     NULL name returns a0(0); ns MinList init head=&tail-slot;
     RemNamedObject falls into ReleaseNamedObject; msg field at
     byte offset +10; UnpackStructureTags writes through *ti_Data.

7. Verified: full oracle output identical to original (all vector
   results, exec-call log, hdr, private data); attn 0x00/0x80/0x02
   patch counts 0/2/6 match; adversarial pack-table streams
   (resync, skip entries) produce identical bytes + identical wild
   reads; rt_EndSkip covers whole code hunk.
