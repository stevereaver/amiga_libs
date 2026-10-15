---
file: defects
---
# Findings

- **DATA hunk declared-vs-physical mismatch**: the hunk table claims
  hunk1 = 0x19 longs (100B) but the HUNK_DATA chunk stores only 4
  longs (16B).  exec allocates 100B, loads 16B; the remaining 84B are
  formally uninitialized but hold the A4 globals — InitCEnv clears
  exactly 21 longs (0x54B) from +0x10, covering the gap.  Classic
  SAS/C slink output quirk.
- **HUNK_SYMBOL tables survive** in both hunks (40 + 5 syms) —
  unusual for a shipped library; gives full function names.
- **SAS/C small-data model**: A4 = data-hunk base via
  `lea EndSkip,a4` (EndSkip = symbol at h1+0, stored operand 0,
  patched by RELOC32->h1).  Every public function reloads A4.
- **Oracle artifact**: fuzzing vectors with zeroed arg blocks lets a
  call scribble over low memory (incl. AbsExecBase @4) — the later
  Close->Expunge path then loads A6=0 and the CloseLibrary JSR goes
  wild, landing on the exec-1194 trap stub and returning sanely.
  Deterministic and identical orig-vs-rebuild; harness artifact, not
  a lib defect.
- **Deltas vs siblings**:
  - vs 34.5: same absolute-long functab format (34.5: 20 entries,
    entry0 NULL -> Open not installed; 37.3: 14 entries, all used).
    34.5 is a single-hunk hand-asm build; 37.3 is 2-hunk SAS/C C.
    NOTE: the 34.5 doc calls exec -558/-564/-570 "resource/ICR"
    calls — they are actually InitSemaphore and
    Obtain/ReleaseSemaphore (cia ICR calls go through resource
    bases at -6/-12, not exec).
  - vs 40.2: 40.2 uses word-offset functab (19 entries incl.
    reserved) and a separate DATA hunk just for resource-name
    strings; 37.3 keeps strings inline in CODE and uses absolute
    longs.  Both are AUTOINIT with InitTable @h0+0x4a and share the
    FalseStart + resident layout.
  - 37.3 init opens misc.resource + dos/utility **v33** (40.2:
    utility v37 for version stamping; 34.5: utility v37 + sems).
    37.3 InitSemaphore's two lib-private semaphores at +0x44/+0x72.
- **Reserved LVO -24** is a real stub (+0x14a), not an alias — no
  trailing reserved slots exist (table ends at -84).
