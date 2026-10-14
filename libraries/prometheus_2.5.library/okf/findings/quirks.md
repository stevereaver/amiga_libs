# prometheus.library 2.5 — quirks & inconsistencies

- **WriteConfig arg order contradicts the public API docs**: the 2.5
  WriteConfigLong/Word/Byte vectors take `d0 = offset, d1 = data`
  (data/offset swapped relative to the documented `d0 = data,
  d1 = offset`). The bug was kept through the whole 2.x line and only
  fixed in prometheus.library 3.0; callers of 2.5 must use the swapped
  order. Preserved verbatim.

- **COLDSTART + self-MakeLibrary**: rt_Init is a full init routine that
  calls `MakeLibrary` with the hunk1 functab itself rather than using
  AUTOINIT/InitStruct; OpenCnt is seeded to 1, so the board driver lib
  cannot be expunged through Open/Close alone — an explicit Expunge
  while open only sets DELEXP, and it fires on the *next* Close below 1.

- **OpenCnt seeded to 1 at init**: like several boot-time libs,
  `lib_OpenCnt = 1` on creation — the only way to free it is Expunge
  after Close brought the count to... actually the count can never
  reach 0 through Open/Close (min is 1). Expunge directly tests
  `opencnt==0`, so even a forced expunge with the seed present defers
  forever. Effective behavior: the library is resident for the life of
  the system once init succeeds.

- **`_sizetopri` = log2 via trailing-zero loop**: Enqueue priorities
  for SpaceReq nodes are `ctz(size)` — big requests are sorted before
  small ones (descending ln_Pri). Allocates top-down so this matches
  the intent.

- **`AddTail` on a MinList (-246)**: _querycard links PCIBoard nodes
  with exec AddTail against a NewList-initialized 12-byte header —
  works because MinList and List share the head/tail layout; ln_Type
  is left unset (0) rather than NT_UNKNOWN.

- **WriteAddresses keeps `tstl a2@` terminator**: the request walk
  stops on `ln_Succ == NULL` — the final node itself is skipped.
  Harmless for the priority-sorted list (requests are enqueued, so the
  tailmost is smallest) but a genuine off-by-one walk.

- **`notb d0` trick**: `moveq #67,d0; notb d0` produces 0xffffffbc =
  ~67 — the PCIBoard alloc size is *-68* (i.e. 0xffffffbc passed to
  AllocPooled); the code relies on AllocPooled masking/rounding — or
  it's a compiler `sizeof` artifact; preserved.

- **`findconfigdev` iteration**: init loops `FindConfigDev(prev,
  0xad47, 1)`; each board found is scanned — the ConfigDev the
  expansion library hands over is mutated (`cd_Driver=pb`,
  `cd_Flags &= ~2`), marking it claimed.

- **Single `if (o&1) o+=1` hunk pad**: file layout has no odd hunks;
  endskip=0x1e points one word past rt_Init as usual.
