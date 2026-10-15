---
file: vectors
---
# Vectors (8 abs-long, via MakeLibrary functab)

-6 Open ->lib | -12 Close ->0 | -18 Expunge (2x exec -414
FreeMem-260 + Remove) | -24 stub | -30 returns 0x464f4e54
('FONT' cookie) | -36 ->2 | -42 font op (2x exec -1398 =
utility/date or AvailFonts helper + AllocMem-260) |
-48 exec -210 call.

expunge path verified: Remove + FreeMem(126).
