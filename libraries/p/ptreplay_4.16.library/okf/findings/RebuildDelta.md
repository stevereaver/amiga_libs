# Rebuild delta

- Semantic port; not byte-identical.  The replay engine body
  (PTUpdate/PTRenderInit + the spawned server/ctrl tasks) is
  stub-shaped in the C model - the server process image lives in
  the original's work loop and would need a dedicated pass.
- Function names follow the public ptreplay API.
