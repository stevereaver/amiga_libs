---
file: vectors
---
# Vectors

41 LVOs (-6 .. -246), absolute functab@h0+0x17a ->h0.

open/close/expunge/reserved + 37 MMXV API entries. Observed:
close/expunge do CloseLibrary(-414) on cached mmv8/mmv88 bases,
Remove(-252) + FreeMem(-210) 112B; user vectors OpenLibrary(-552)
'mmv88.library' v8+ then 'mmv8.library' v22+ and forward,
returning 0x7b sentinel when absent (-144 returns 0x7f;
-72/-138 return -1; -186/-192 do audio.device
OpenDevice(-444)/CloseDevice(-450) via FindTask(-294)).
initfn: node fill + OpenLibrary(-552) 'dos.library'@h0+0xe6b
-> h0+0xe84.
