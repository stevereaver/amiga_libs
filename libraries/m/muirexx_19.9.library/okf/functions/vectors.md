---
file: vectors
---
# Vectors (abs-long functab @h0+0xe40, 13 entries, -1 term)

-6  Open    ->h0+0x464  opencnt++ @lib+0x20; bclr #3,lib+0xe;
        ObtainSemaphore(lib+0x26); on 1st open bsr h0+0x520:
        OpenLibrary dos/utility/intuition v36 + muilowlevel v19
        -> BSS+4/+8/+0xc/+0x10 (on any fail closes opened ones,
        ret 0 -> opencnt--); ReleaseSemaphore; ret lib or 0.
-12 Close   ->h0+0x4a8  ObtainSemaphore; if opencnt==1 bsr
        h0+0x59a: CloseLibrary all four bases, zero BSS slots;
        ReleaseSemaphore; opencnt--; if 0 && flag3 -> tail-call
        Expunge; ret 0 (or seglist from nested expunge).
-18 Expunge ->h0+0x406  if opencnt!=0 -> bset #3,lib+0xe, ret 0
        (deferred); else bsr h0+0x50a (always 1), Remove(lib)
        [exec -252], FreeMem(lib-negsz, negsz+possz) [-210],
        ret seglist from lib+0x22.
-24         ->h0+0x0    *relocated-0 slot* — functab entry is 0
        covered by RELOC32->h0, lands on CODE+0 reserved stub
        (`moveq #0,d0; rts`), ret 0.
-30 ->h0+0x8c6  returns &stdcmdtab (h0+0xd4): the 7-record
        builtin ARexx command table (quit/hide/deactivate/
        show/activate/info/help).
-36 ->h0+0x8d8  command dispatcher: big frame (44B), walks the
        two 0x24-strided tables chained at msg+0xd8/+0xdc,
        matches name via strncasecmp helper (h0+0x1274), calls
        handler (jsr a6@ where a6=entry slot), BuildRexxMsg-ish
        reply path via BSS+0xc (intuition) -648, FillRexxMsg/
        reply via msg fields; error codes -1..-4 to caller's
        result ptr (sp@(60)).
-42 ->h0+0xaf6  if a0!=0: d7 = 1 << *(a0@+15) (bit number from
        a byte in the pointed-to struct); ret bitmask.
-48 ->h0+0xb1c  WaitPort [exec -372] loop driver: a5=a0 port-ish
        struct; WaitPort(a5@), checks ln_Type byte==7, calls
        msg+0x28 hook via a6@-132/-150 (signal alloc/free),
        decrements a5@+8 count, d7=has-a5@+0x20.
-54 ->h0+0xb7c  PutMsg [exec -378] wrapper: a3=a1 msg, fills
        msg+0x20/0x24 (argstr copy via a6@-126 on a1@+4 base if
        a2 string && msg bit1@0x1d), then PutMsg(a0 port,a1 msg).
-60 ->h0+0xbdc  name busy-check: calls helper h0+0xe78 (opens
        rexxsyslib.library, CreateRexxMsg -168, CloseLibrary),
        strlen a2, bsr h0+0xf18 (name lookup); ret bool d7.
-66 ->h0+0xc2a  build/send ARexx msg: calls a5@+4 (RexxSysBase)
        -144 (CreateRexxMsg-ish: a1=&a5@+0x2c, d0=a5@+0xc),
        sets msg+0x1c flags (0x40000 | wet bit from d0 arg),
        argstr via rexx -126, exec -390 on "_"; ret d6 bool.
-72 ->h0+0xce4  teardown: a5@+0xc="_" marker, drains port
        (GetMsg loop -384), calls -48/-54 helpers with d0=100
        and a2->h0+0x33c ("99: Port Closed!"), frees via -150.
-78 ->h0+0xd9e  create handle: AllocVec(52,MEMF_CLEAR|0x10000)
        [-684], OpenLibrary("rexxsyslib.library",0)->h+4,
        copies <=7-char basename from a1 (or "rexx") to h+0x2c,
        stashes a0->h+0xc, bsr h0+0x10c8 register/validity loop;
        on fail bsr 0xce4 teardown + ret 0.

initfn: not AUTOINIT — see structures/layout.md (rt_init code
@h0+0x374 does its own MakeLibrary + AddLibrary).
