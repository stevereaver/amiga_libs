# Findings & defects

- initfn returns 0 under stub deps (AmiSSL master needs versioned
  amissl_v*.library siblings in LIBS:AmiSSL/); dispatcher vectors then
  return 0x80 / 0x8000000c error codes — deterministic.
- Close opencnt underflow PRESENT (same as 5.1/5.7): after 2 opens
  (cnt latched at 1) a single Close drives lib+0x20 to 65535.
- h1 is tagged DATA with only 32B initialised but a 0x34-long (208B)
  memory allocation — the uninitialised tail doubles as BSS. It holds
  no executable stub bytes (zeros + 0x24@+0x14; the +0x14 value is the
  required sublib-version threshold: 0x24 here, 0x20 in 5.7, 0x15 in
  5.1, matching the -30 compare immediate 36/32).
- Second Open does not increment opencnt past 1 (open -> cnt=1 twice).
- 1704 deterministic invalid accesses; identical on rebuild.
- Diff vs 5.7(020+): +0xe8B h0 code growth; version-tag table grows
  27->37 entries (adds 332,331,330,321,320,314,313,312,311,310);
  vectors -30/-36/-42/-48/-54/-60 relocated; rev field 17.
