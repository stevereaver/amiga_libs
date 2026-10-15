# Structures

## XpkSubParams (codec argument block, via a0)

| off | field |
|-----|-------|
| 0x00 | xsp_InBuf |
| 0x04 | xsp_InLen |
| 0x08 | xsp_OutBuf |
| 0x0c | xsp_OutBufLen (ignored by the encoder) |
| 0x10 | xsp_OutLen (written only on success, by pack) |
| 0x14-0x30 | flags/number/mode/password/version/tags |
| 0x34 | xsp_Sub[4] -- [0] = workmem pointer (buf+4) |

## Descriptor (hunk+0x36c, static)

60-byte XpkInfo + 32-byte XpkMode + strings; the
"cremation" string at 0x3e4 is referenced nowhere.
