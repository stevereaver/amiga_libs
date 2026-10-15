# Findings & defects

- Close underflows the open count (cnt=65535) then still
  remove/free the library — same underflow defect family seen in
  bfbplay/protracker/amisslmaster/pccard.
- 30 deterministic invalid accesses during vector probing
  (synthetic args dereferenced); identical orig vs rebuild.
- DREL16 relocation tail instead of the usual RELOC32.
