# Log

## 2026-10-10T15:15:51Z -- reconstruction complete

- Parsed HUNK (1 code hunk, 1068B image), RomTag (AUTOINIT
  v1), InitTable@0x92 (dataSize 0x30), functab (19 vectors),
  datatab, and full 0x112-0x42a code region.
- Resolved all exec/dos LVOs: exec -552/-414/-252/-210;
  dos -306 FGetC, -204 WaitForChar, -312 FPutC, -342 FPuts,
  -360 Flush.
- Identified library as console hex-I/O toolkit for the
  AmigaFlight debugger; ABI: handle in a1, string arg in d2
  for -102, multi-register return for -66, carry-flag error
  channel for -30/-54.
- Found dead duplicate prompt routine at 0x2d0 (a6 misuse,
  would crash) and three dead CRLF copies.
- Reconstructed in C + asm vectors (carry/multi-reg contract),
  byte-identical datatab, all LVO call sites verified.
