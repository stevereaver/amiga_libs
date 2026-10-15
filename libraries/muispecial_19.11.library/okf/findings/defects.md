# muispecial.library — quirks and defects

1. **NP_StackSize = 5**: `_v48` passes tag `0x800003f5` with value 5
   (`pea.l $5.w`) to CreateNewProc — a five-byte process stack. On a
   real system CreateNewProc would either clamp it or the process
   would overflow immediately. Almost certainly meant to be a larger
   value.

2. **Return values carry stale upper bits**: `_v48` returns via
   `move.w d6,d0` leaving upper bits from earlier calls (observed
   0x20001). Callers must test `d0.w`, not the full long.

3. **-42 stub returns its first argument**: `_v42` pushes d0-d2/a0
   but never touches them; d0 passes through unchanged — the "stub"
   returns whatever the caller passed.

4. **s: scan by file size**: `_finddata`'s fallback iterates `s:` and
   accepts the first file whose `fib_Size == 0x15a09` — a fragile
   magic-size heuristic for locating mti.data.

5. **Expunge blocked by live process**: `_closedeps` refuses (returns
   0) while gd+0x10 holds a process pointer; the audio process clears
   it under Forbid on exit. If the process dies abnormally the flag
   stays set and the library can never expunge.

6. **`lea.l $0.l,a4` idiom**: every global access goes through
   absolute-0 long loads relocated to the data hunk — standard SAS/C
   near-data. All `movea.l $0(a4),a6` sites encode the
   noncanonical mode-5 disp16-zero form (gas folds these to the 2-byte
   mode-2 form; reconstruction raw-emits the 4-byte forms).

7. **Mode-5 disp-0 encodings**: 25 sites use `xx6c 0000`-style
   explicit zero displacement — preserved byte-exactly.
