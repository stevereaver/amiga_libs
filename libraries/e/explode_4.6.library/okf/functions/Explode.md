# Explode - LVO -30

Decrunch, relocate and run.  This is the library's only public vector.

## Calling convention (shipped, register-level)

```
    movem.l d0-d7/a0-a6,-(sp)   ; caller saves all regs
    jsr     -30(a6)             ; a6 = explode.library base
    ; packed stream follows INLINE right after the JSR:
    <32-byte hunk-node header + packed blob>
```

The function pops its own return address into A5 and uses it as the
packed-stream pointer: the 32 bytes immediately after the JSR hold the
hunk node table (`stream - 32` = chain base), the blob follows.

A 0x3e-byte frame is built on the stack.  Task priority is raised to
15 during decode (`FindTask`/`SetTaskPri`; task/oldpri are kept on the
stack, not in the frame as in 4.3) to limit preemption.  On completion
the routine does NOT return normally: it writes `chain[0]+4` over the
caller's saved return slot, restores all registers and `RTS`-jumps
into the decrunched program's entry point.

## Memory layout of a loaded "exploded" file

```
hunk[0]  : [size][next-bptr][32B node table + packed stream ...]
hunk[1..n-2] : output segments (receive payload + relocs)
hunk[n-1]: ring / staging buffer (size-8 bytes)
```

The packed bitstream is read BACKWARD from the end of the
second-to-last hunk's data.  Decompressed bytes are written into the
ring (last hunk); a tag-driven copy-out loop then walks the stream of
4-byte records - payload, segment separator (negative), or a
relocation group - and patches the output hunks.  Finally the two
staging hunks are FreeMem'd and execution jumps to chain+4.

## Register map (original)

A0 stream cursor, A2 ring pull cursor, A3 ring write / seg base,
A5 match source (persists across refills), A6 ring low bound,
D1 bit reservoir, D2 literal count, D3 distance class,
D4 ring size, D5 ring space / segment index.
