# Vectors (10, absolute long, LVO -6..-60)

| LVO | Notes |
|-----|-------|
| -6/-12/-18 | Open/Close/Expunge @h0+0x58... |
| -24 | reserved -> 0 |
| -30 | -> 0 under stub args |
| -36..-54 | -> 0x80 (error code paths — initfn returned 0 under stubs) |
| -60 | -> 0x8000000c |

Vectors appear to dispatch/version-check into versioned amissl_v*
sublibraries (master-lib pattern); under no-subllib environment they
return error codes deterministically.
