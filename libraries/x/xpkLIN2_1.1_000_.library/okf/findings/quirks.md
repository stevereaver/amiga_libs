# Quirks / defects (all reproduced verbatim)

## Skeleton quirks (shared "1 Oct 2013" generation with DUKE/NUKE 1.8)

1. **`rt_EndSkip = 0`** — the RomTag end marker points at offset 0,
   not at end of module.  Harmless for AUTOINIT libraries.

2. **Entry stub returns 0**, not -1 (`moveq #0,d0; rts` vs MASH's
   `moveq #-1`), and doubles as the null-vector target — functab
   entries `-24`/`-48` are `0xff6c` = `-functab`, a *backward* offset.

3. **"return 0" via long branch to code+0** — Close's early exits
   (`bne.w`, `beq.w`, `bra.w` with negative displacements) all jump to
   the module entry stub instead of a local `rts`.

## LIN2-specific

4. **`xsp_Password` dereferenced without NULL check** on the first
   PackChunk (when `xsp_Sub[0]==0`): `movea.l 0x20(a0),a1; tst.b
   (a1)` — a NULL password pointer reads address 0.  (XpksUnpackChunk
   only touches the password when `stream[0:4] != 0`.)

5. **Password hash embedded in the stream.**  Pack writes
   `pwhash(pw)` at output[0:4] (0 when pw is empty/"").  Unpack
   requires `stream[0:4]==0` **or** `pwhash(xsp_Password)` equal —
   else **-32** (observed).  The hash (`(h<<4)|c`, plus `sum` of all
   bytes, `0x01010101` when the result is 0) is weak additive/rotate,
   not crypto.

6. **`XpkSubFree` returns stale d0** — when `xsp_Sub[0]==0` it just
   `rts`s without setting a return value (observed `PackFree ->
   0xffffffe0`, leaking the previous -32).

7. **Mode is latched.**  The mode -> {buffer size, submode} choice
   (and the password hash) happens only when `xsp_Sub[0]==0`.
   Changing `xsp_Mode` between PackChunk calls without a PackFree has
   no effect — verified: mode30/60/100 select buffers
   0x4900/0x8900/0x10900 and submode 5/6/7 only on fresh Sub[0].

8. **XpksPackReset (-48) is a null vector.**  The matcher's head
   table is zeroed inline at the top of every PackChunk anyway, so
   no explicit reset exists.

9. **-17 doubles as "outbuf overflow" and "not smaller".**  Both the
   mid-stream bound check (`a3 >= OutBuf+InLen`) and the final
   `xsp_OutLen >= xsp_InLen` return -17.  Small/incompressible inputs
   (<~64 B typically) always get -17; `xsp_OutLen` is NOT reset on
   failure (stays whatever the caller left / partial value).

10. **Unpack requires preset `xsp_OutLen`** and compares it against
    the produced byte count (minus the InBuf[8] pad-nibble count);
    mismatch -> **-14**.

11. **Backward 0xff scan.**  Unpack locates the tail-block boundary
    by scanning *backward* from `InBuf+InLen-1` for a `0xff` byte —
    a stream without one runs the pointer below the buffer
    (unbounded OOB read).

12. **`xsp_Sub[0]` is shared between pack and unpack.**  Calling
    UnpackChunk after PackChunk reuses the 0x4900..0x10900 pack
    buffer as if it were the 0x20-byte unpack state block (it just
    needs the table region).  PackFree (-42) and UnpackFree (-60)
    are literally the same routine.

13. **Typo in the info block:** `xi_PackMsg = "Comressing"` (sic,
    missing 'p').  `xi_Name` is "LINO2" while the fourcc is 'LIN2'
    and the long name "Lino2 V1.1".

14. **`xi_Flags = 0xa009`** — one extra bit vs the common 0x8009
    (0x2000 set; whatever flag that is).

15. **Version fields inconsistent:** datatab writes
    lib_Version=1, lib_Revision=1 and XpkInfo says
    xpkver=1/subver=1/masterver=2/modesver=0 while the idstring
    claims "V1.1".

16. **Window is only 0x7f7c (32636) bytes** — match distances are
    16-bit-ish (`cmpi.l #0x7f7c` gate), consistent with
    `DefPkInChunk=0x8000`.  `MaxPkInChunk=0x7fffffff` is a lie of
    optimism; correctness relies on the master chunking at ~32K.

## Assembler notes (reconstruction)

17. Thirteen instructions are emitted as `.short` verbatim because
    gas encodes them differently or can't express them (list in
    `work/patch000.txt`):
    - `lea.l label(pc)` at 0x132 (XpksPackerInfo)
    - `bsr.w _strhash` at 0x15a, 0x798 (x2)
    - `movea.l $0(a0),ax` at 0x216, 0x766, 0xa56 — gas drops the
      explicit 0 displacement (x3)
    - mem-to-mem byte moves gas can't express: `move.b
      (a6,d5.w),-(a2)` (0x6ce, 0x6e0), `move.b (a0)+,(a3)+`
      (0x6fa, 0x812, 0x818, 0x81a), `move.b -(a5),(a3)+` (0xa26),
      `move.b (a1,d0.w),(a3)+` (0xa3e)
