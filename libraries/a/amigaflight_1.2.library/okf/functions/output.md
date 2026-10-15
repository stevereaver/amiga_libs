# Output vectors

## AFPutChar (-72, @ 0x30c)

`FPutC` (-312) then `Flush` (-360) on the handle in a1.
Flushing after every character is interactive-safe but slow;
all higher-level outputs inherit it.

## AFPutNibble (-78, @ 0x330)

`(n & 0xf) + '0'`; if > `'9'` adds 7 -> `A-F`. Tail-calls -72.

## AFPutByte (-84) / AFPutWord (-90) / AFPutLong (-96)

Hex formatters: byte via rotate-pair of nibbles, word via
`rorw #8`, long via `swap` -- 2/4/8 digits, no `0x` prefix.

## AFPutString (-102, @ 0x3e8)

`FPuts` (-342) + `Flush` (-360). **The string pointer arrives
in d2, not d0/d1** -- unusual ABI; d0 callers must be careful.

## AFPutSpace (-108, @ 0x408) / AFPutSpaces (-114, @ 0x414)

Space padding: `-114` counts down from the `d0` word argument
(a `dbf` loop -- arg 0 emits 0 spaces, arg 0x10000 wraps as
a word so effectively max 65535).

## AFNewLine (-36, @ 0x1de)

Emits 10 (LF) then 13 (CR) -- the **reverse** of the usual
CR-LF sequence. On most Amiga consoles order is harmless;
it is still a shipped quirk.
