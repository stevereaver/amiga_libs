# Structures

## XpkSubParams (codec argument block, via a0)

| off | field |
|-----|-------|
| 0x00 | xsp_InBuf |
| 0x04 | xsp_InLen |
| 0x08 | xsp_OutBuf |
| 0x0c | xsp_OutBufLen (ignored by encoder) |
| 0x10 | xsp_OutLen (written only on success, by pack) |
| 0x14-0x30 | flags/number/mode/password/version/tags |
| 0x34 | xsp_Sub[4] -- [0] = workmem pointer (sub = buf+4) |

## Workmem layout (0x44004 bytes)

| off | size | use |
|-----|------|-----|
| buf+0x0 | 4 | allocation size, for PackFree's FreeMem |
| sub+0x00000 | 262144 | ULONG hash[65536]: last pos per 16-bit hash |
| sub+0x40000 | 16388 | ULONG chain[4097]: prev pos, ring idx pos&0xfff |

`hash = (b0 << 8) | ((b1 + b2) & 0xff)` -- the shipped code
computes it as `(0xffff0000 | h) << 2` so a single base at
sub+0x40000 indexes the table at sub via the negative offset.

## Descriptor (hunk+0x368, static)

88-byte XpkInfo + 42-byte XpkMode + strings.
