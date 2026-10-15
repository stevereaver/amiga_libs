# Findings & defects

- Unlike 3.41, Close decrements cleanly (cnt=0) and expunge
  returns 0x2b0f after forced close — later build regressed
  to underflow.
- OldOpenLibrary(-408) dep convention (WB1.x).
- ~8 deterministic invalid reads at functab edge.
