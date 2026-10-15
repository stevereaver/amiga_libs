# Findings & defects

- initfn result unused-ish: returns 0 under stubs (intuition
  open returns 0x80000 fake base; real init path still traces).
- Close count underflow (unguarded decrement): 65534.
- A few deterministic invalid reads probing functab-adjacent
  memory (7 early reads during -24..-36 region probing).
