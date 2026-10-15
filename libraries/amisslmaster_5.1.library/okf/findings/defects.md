# Findings & defects

- initfn returns 0 under stub deps (expected: AmiSSL master needs
  versioned amissl_v*.library siblings); vectors then return
  0x80/0x8000000c error codes — deterministic.
- h1 is a DATA hunk containing executable stub bytes — unusual
  tag/content mismatch.
- Close underflows opencnt (cnt=65535 after 2 closes past 0).
- 1704 deterministic invalid accesses; identical on rebuild.
