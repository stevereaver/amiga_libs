# Findings & defects

- initfn returns 0 under stub deps (AmiSSL master needs versioned
  amissl_v*.library siblings in LIBS:AmiSSL/); dispatcher vectors then
  return 0x80 / 0x8000000c error codes — deterministic.
- Close opencnt underflow PRESENT (same as 5.1): after 2 opens
  (cnt latched at 1) a single Close drives lib+0x20 to 65535.
- h1 is tagged DATA with only 32B initialised but a 0x34-long (208B)
  memory allocation — the uninitialised tail doubles as BSS. Unlike
  the 5.1 okf note, it holds no executable stub bytes (verified:
  zeros + 0x20@+0x14; the "stub" claim in the 5.1 bundle does not
  match its shipped bytes either — 5.1 h1 is zeros + 0x15@+0x14).
- Second Open does not increment opencnt past 1 (open -> cnt=1 twice).
- 1704 deterministic invalid accesses; identical on rebuild.
