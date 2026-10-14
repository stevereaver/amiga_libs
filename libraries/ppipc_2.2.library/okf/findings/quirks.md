# ppipc_2.2.library — quirks & inconsistencies

1. **DOS stub returns 20**: hunk0 starts `moveq #20,d0; rts` —
   a plain `ppipc.library` invoked as a program returns 20 (fail/warn
   range), not the usual `moveq #0`. Deliberate or leftover version
   number.

2. **AUTOINIT + datatab ver/rev mismatch**: InitStruct writes version 1 /
   revision 0 (matching the RomTag rt_Version=1), then initfn
   *overwrites* lib version/revision with the words at hunk2+0x2a/0x2c
   (2,2) — the datatab fields are dead. The on-disk idstr "2.2" is the
   marketing version; the RomTag only claims v1.

3. **Stack-arg helpers, register-arg vectors**: the hunk0 helper trio
   (`NewList`, `strlen`, `strcpy`) all take their args on the stack
   (`moveal sp@(4),a0` — including a *pointer* arg via `moveal`, not
   `movel`), while the real API vectors take register args (a0/a1/d0).
   Mixed convention, typical of a C build with inlined support routines.

4. **`moveal` on a list head**: init's NewList helper does
   `moveal sp@(4),a0` where the caller pushed `pea _portlist` — the arg
   is the list pointer itself, fine, but `_mkport` pushes `pea` of the
   *address of* an AllocMem'd node too. Works because both callers pass
   a real address; `moveal` vs `movel` is just the compiler's choice.

5. **Cross-hunk calls via jmp stubs**: h5 and h7 cannot `jsr` h0/h5
   directly (linker emitted absolute-long relocations, no PC-rel
   cross-hunk calls), so each consumer hunk carries a row of
   `jmp abs.l` stubs: h3 has 1, h5 has 3 (t_strlen/t_newlist/t_strcpy),
   h7 has 11. The original linker laid these stubs at the hunk tail in
   descending order (relocs at 0x118→0xfa descending).

6. **h10 wrappers reload a6**: `_getmsgstub`/`_waitstub` do
   `movea.l (h1+0x32).l,a6` before `jmp (exec-372/-384).l` — they exist
   solely so broker code can call GetMsg/WaitPort when a6 isn't exec.
   No functab entries point into h10; reached only via h7 stubs.

7. **Expunge emptiness test**: checks `*(portlist.lh_Head) == 0` i.e.
   "first node's ln_Succ is NULL" — the tail sentinel trick: after
   NewList, lh_Head=&lh_Tail whose first word pair is 0. Works, but
   reads the first *long* of the sentinel rather than testing lh_Head
   against &lh_Tail directly.

8. **-42/-48 flag-bit0 test**: both test `btst #0,port+41` — bit 0 of
   the *low* byte of the flags word — before Signalling sigtask. -72
   rewrites that whole low byte from d0 (owner-task only), so callers
   arm/disarm per-use signalling plus 7 other flags at once. The 0x1000
   bit of the 0x9000 ready mask is never assigned by any vector.

9. **PortSignal is one-shot**: -54 checks `flags & 0xc000` first and
   *fails* (ReleasePort + return 0) if either top bit is set — calling
   it twice on the same port, or after SetSigMode raised 0x4000, always
   returns 0. -60 SetSigMode sets 0x4000 and *clears* 0x8000
   (`bset#6` on the high byte + `andiw #0x7fff`), i.e. marks the port
   "sig-mode set" while masking off the ready bit; -66 then keeps only
   `flags & 0x3f00`. sigbit at +0xf is never cleared after FreeSignal —
   a stale bit number remains.

10. **Broker is best-effort**: -96 swallows every failure (no broker
    port, alloc failure, putmsg refused) into the same cleanup path and
    returns the port only if the ready mask is set at the end — a caller
    cannot distinguish "broker absent" from "request in flight".

11. **Overlapping hunk sizes**: hunk4 is a single 4-byte DATA cell and
    hunk8 a single 16-byte string — the original link kept every
    translation unit's sections as separate hunks rather than merging
    .data/.bss, hence the 11-hunk file for only ~2.6 KB.
