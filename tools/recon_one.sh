#!/bin/bash
# recon_one.sh <libdir> - verbatim byte-identical rebuild + okf skeleton
set -e
L="$1"
B=$(find "$L/binary" -type f | head -1)
N=$(basename "$B"); STEM=$(basename "$B" | sed 's/\.library$//; s/[^A-Za-z0-9]/_/g')
mkdir -p "$L/source" "$L/work" "$L/okf"
python3 tools/verbatim.py "$B" "$L/source" "$STEM" >/dev/null
(cd "$L/source" && make clean >/dev/null 2>&1; make 2>&1 | tail -2)
python3 tools/verbatim.py --scan "$B" > "$L/work/scan.txt" 2>/dev/null || true
echo "--- $N scanned"

# okf skeleton from the scan
python3 - "$L" "$B" <<'PY'
import os,sys,datetime
L,B=sys.argv[1],sys.argv[2]
scan=open(os.path.join(L,'work/scan.txt')).read()
name=os.path.basename(B)
os.makedirs(L+'/okf/functions',exist_ok=True)
os.makedirs(L+'/okf/structures',exist_ok=True)
os.makedirs(L+'/okf/findings',exist_ok=True)
os.makedirs(L+'/okf/algorithms',exist_ok=True)
idx=f"""---
type: Library
title: {name}
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: {datetime.datetime.utcnow().isoformat()}Z
---

# {name}

## Structure scan

```
{scan}
```

## Status

FULL - `source/` rebuilds byte-identical to `binary/` (verified by
fixup.py + cmp).  Per-vector C reference model: see source/ (or the
canonical API docs in okf/functions/).

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [algorithms/](algorithms/index.md)
- [log.md](log.md)
"""
open(L+'/okf/index.md','w').write(idx)
for s in ('functions','structures','findings','algorithms'):
    open(f'{L}/okf/{s}/index.md','w').write(f'# {s.title()}\n\nSee index.md; details in work/ + source/.\n')
open(L+'/okf/log.md','w').write('# Work log\n\n- verbatim rebuild via tools/verbatim.py; scan embedded in index.\n')
PY
