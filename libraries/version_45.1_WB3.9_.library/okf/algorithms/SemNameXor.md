---
type: Algorithm
title: Semaphore-name XOR obfuscation
description: The hidden probe XORs 10 in-.text bytes with a caller-supplied key byte before FindSemaphore and restores them after.
---

# Semaphore-name XOR obfuscation

The hidden routine at text+0xd4 keeps the semaphore name in the
code hunk XOR-obfuscated:

```
for (i = 0; i < 10; i++) name[i] ^= key;   /* eor.b d2,(a0)+ / dbf */
result = FindSemaphore(name);              /* jsr -594(a6)         */
for (i = 0; i < 10; i++) name[i] ^= key;   /* restore obfuscation  */
return result;
```

- Encrypted bytes: `42 c9 a0 b9 9b 8c 8f 9a c9 52` (identical in
  44.2, 45.1 and 45.5).
- The key is **not** embedded — it is the d0 argument, so the
  plaintext cannot be proven from the binary alone.
- With key `0xE9` the bytes decode to `« IPrefs »` (bytes
  `ab 20 49 50 72 65 66 73 20 bb`); the guillemets are printable
  in the Amiga-1251 charset, making a semaphore literally named
  `« IPrefs »` plausible.
- A NUL terminator follows the buffer (hunk pad byte), so the
  decoded string is a valid C string for `FindSemaphore`.
