# SvcFormat (-36, @0x448)

Stack-arg function: dst = sp@(20), fmt = sp@(24),
varargs = &sp@(28).

    RawDoFmt(fmt, &varargs, putch_hook, dst)
    hook: moveb d0,a3@+  (append + advance cursor in a3)

Exactly exec's RawDoFmt(-522) with an auto-advancing
byte sink: the a3 userdata is the current write position,
which the hook post-increments.  Returns void (d0 is
whatever RawDoFmt left).

Equivalent to `svcprintf(dst, fmt, ...)`.
