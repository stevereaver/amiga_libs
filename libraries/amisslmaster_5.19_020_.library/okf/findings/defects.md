# Findings & defects

- initfn returns 0 under stub deps (AmiSSL master needs versioned
  amissl_v*.library siblings in LIBS:AmiSSL/); dispatcher vectors then
  return 0x80 / 0x8000000c error codes — deterministic.
- Close opencnt underflow PRESENT (same as 5.1/5.7/5.17): after 2 opens
  (cnt latched at 1) a single Close drives lib+0x20 to 65535.
- h1 is tagged DATA with only 32B initialised but a 0x34-long (208B)
  memory allocation — the uninitialised tail doubles as BSS. It holds
  no executable stub bytes (zeros + 0x26@+0x14; the +0x14 value is the
  required sublib-version threshold: 0x26 here, 0x24 in 5.17, 0x20 in
  5.7, 0x15 in 5.1, matching the -30 compare immediate 38/36/32).
- Second Open does not increment opencnt past 1 (open -> cnt=1 twice).
- 1704 deterministic invalid accesses; identical on rebuild.
- Diff vs 5.17(020+): +0x34B h0 code growth; version-tag table grows
  37->39 entries (adds "341","340" for amissl_v341/amissl_v340);
  h1+0x14 0x24->0x26; vectors relocated (early entries +2, later more);
  resident @+0x96 (vs +0x94); id date 11.2.2025; rev field 19.
