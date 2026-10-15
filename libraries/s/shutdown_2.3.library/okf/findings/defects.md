# findings / defects

- **Original is SAS/C manual-init far-data** (3 hunks: CODE+DATA+CODE). The InitFunction writes Library fields directly and copies a context template — this reconstruction uses a standard AUTOINIT skeleton, so the binary layout differs but the API/behaviour is preserved.
- **Resource bookkeeping**: the original opens dos.library + utility.library per context and closes them in ctx_free — matched here.
- The `-30` vector is a bare `return 0` stub in the original (no version/status query).
