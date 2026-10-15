# XpksUnpackChunk (-54)

Byte-loop decoder: positive code copies <code> literals, negative
code repeats the following byte -code times (code is sign-extended
to a LONG before negation, so 0x80 emits 128), 0 ends the stream.
xsp_OutLen is left untouched.  Returns 0.
