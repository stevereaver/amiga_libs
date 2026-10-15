# Findings & defects

- init calls exec -408 (OldOpenLibrary) + exec -108
  (AllocEntry/FreeEntry-family) directly — WB1.x convention.
- functab entry idx 3 is NULL (jmp 0 under harness).
- Close underflows open count (65534).
