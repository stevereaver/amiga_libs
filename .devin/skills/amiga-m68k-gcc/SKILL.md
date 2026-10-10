---
name: amiga-m68k-gcc
description: Build AmigaOS m68k binaries and .library files with the cross toolchain in /opt/amiga (AmigaPorts m68k-amigaos-gcc v16.2)
---

# Amiga m68k cross compiler

Cross toolchain: **AmigaPorts m68k-amigaos-gcc v16.2.0b** ("AmigaDev v16.2", a
maintained fork of bebbo's amiga-gcc). Installed at `/opt/amiga`. Target triple
is `m68k-amigaos`; output is an Amiga **HUNK** binary (`amiga` object format),
not ELF — `readelf` does not work on the output, but `objdump`/`gdb` do.

Add `/opt/amiga/bin` to PATH, or call tools by absolute path.

## Tools (/opt/amiga/bin)

| Tool | Purpose |
|------|---------|
| `m68k-amigaos-gcc` / `-g++` / `-c++` | C/C++ compiler + linker driver |
| `m68k-amigaos-as`, `-ld`, `-ar`, `-ranlib`, `-nm`, `-objdump`, `-objcopy`, `-strip`, `-size` | Binutils (hunk-aware) |
| `m68k-amigaos-gdb` | Source-level debug (e.g. against FS-UAE's gdb stub) |
| `vasmm68k_mot` | vasm assembler, Motorola syntax (`-Fhunk` output) |
| `vobjdump` | Disassembler for vasm `vobj` files — NOT hunk; use `m68k-amigaos-objdump` for hunk files |
| `ira` | Disassembler for Amiga executables/objects (`ira -M68020 file`) |
| `sfdc` | Generates gate stubs / proto+inline headers from `.sfd` library descriptions |
| `fd2sfd`, `fd2pragma`, `mkstub` | `.fd` -> `.sfd`, `.fd` -> proto/inline/clib headers, stub-library builder |
| `lha` | LHA archiver |
| `gg-fix-includes` | NDK include fixup helper |

## Directory layout

- `/opt/amiga/m68k-amigaos/sys-include` — newlib libc headers (default C runtime)
- `/opt/amiga/m68k-amigaos/ndk-include` — AmigaOS NDK 3.x headers (`proto/`, `inline/`, `clib/`, `pragmas/`, `exec/`, `dos/`, `graphics/`, `interfaces/`, `lvo/`, `devices/`, ...)
- `/opt/amiga/m68k-amigaos/ndk13-include` — NDK 1.3 headers (selected by `-mcrt=nix13`)
- `/opt/amiga/m68k-amigaos/{libnix,ixemul,clib2}/{include,lib}` — alternate C runtimes
- `/opt/amiga/m68k-amigaos/ndk/{fd,sfd,fd13,sfd13}` — `.fd`/`.sfd` library description files for 3.x and 1.3
- `/opt/amiga/m68k-amigaos/lib/` — `libamiga.a`, `libdebug.a`, `libm.a`, `crt0.o`, `libb/` + `libb32/` (baserel multilibs), `libm020/`, `libm060/`

OS headers are used as `#include <proto/exec.h>`, `#include <exec/libraries.h>`, etc.

## C runtime selection: `-mcrt=`

| Value | Runtime | Use for |
|-------|---------|---------|
| *(default)* / `newlib` | newlib | General binaries |
| `nix20` | libnix (OS 2.0+) | Same as `-noixemul`; no ixemul.library dependency |
| `nix13` | libnix13 (Kickstart 1.3) | KS 1.3 compat; switches to `ndk13-include` |
| `ixemul` | ixemul.library | POSIX-y programs needing ixemul |
| `clib2` | clib2 | Ports of Unix software (add `-lunix -lnet` as needed) |
| `library` | libnix4 | Shared libraries/devices without a libc `main` |

`-noixemul` is the classic flag; it maps to libnix. Multilib variants under
`libb`/`libb32`/`libm020`/`libm060` are picked automatically by
`-fbaserel`/`-fbaserel32`/`-m68020`/`-m68060`.

## Amiga-specific flags

| Flag | Meaning |
|------|---------|
| `-fbaserel` / `-fbaserel32` | Data addressed relative to a4 (small data model; 32 = 32-bit offsets). Required for libraries/devices |
| `-resident` / `-resident32` | baserel + link as resident (`-m amiga_bss`, `-amiga-datadata-reloc`, `libb`/`libb32`) |
| `-msmall-code` | 16-bit PC-relative branches (needed to stay resident/relocatable) |
| `-mpcrel` | PC-relative code |
| `-ramiga-lib` / `-ramiga-libr` / `-ramiga-dev` | Use `libinit.o` / `libinitr.o` / `devinit.o` startfile (libnix library/device skeleton) |
| `-m68000`...`-m68060`, `-mcpu=`, `-march=`, `-mtune=` | CPU selection. **Default is 68020** — pass `-m68000` for stock A500/A600/A1200 compat |
| `-m68881` / `-mhard-float` / `-msoft-float` | FPU selection (default soft-float) |
| `-fbbb=...` | Bebbo extra optimizations; `+` = all (on by default), `-fbbb=` disables |
| `-mregparm=N` / `-msasregparm` | Pass args in registers / SAS-C-compatible regparm |
| `-g` | Debug info — also emits `-amiga-debug-hunk` (Amiga-native debug hunks) |
| `-Wl,...` | Linker opts: `-m amiga_bss`, `-amiga-datadata-reloc`, `-amiga-debug-hunk` |

Not supported in this fork: `-mrestore-a4`, `-malways-restore-a4` (silently
swallowed as bogus `-Werror=` args — do not use).

## Calling conventions / function attributes

Provided by `clib/compiler-specific.h` (pulled in via NDK headers) when
`__GNUC__ && AMIGA` — all predefined, just include OS headers:

- `REG(a0, type name)` style register args: GNU spelling is
  `type name __asm("a0")`. The `REG` macro (`#define REG(reg,arg) arg __asm(#reg)`)
  is defined in `libinit.h`/`pool.h` (libnix) — define it yourself if needed.
  Example that compiles to `move.l a0,d0`:
  `LONG AddTwo(LONG x __asm("a0")) { return x + 2; }`
- `__saveds` — entry point loads a4 with the library's data base (required on
  exported library functions when built `-fbaserel`)
- `__interrupt` — set condition codes from d0 on exit (interrupt handlers)
- `__stdargs` — stack args (varargs-capable library entry points)
- `__chip` / `__fast` / `__far` — memory-type placement attributes
- Inline asm uses Motorola syntax: `movel`, `sp@-`, `jbsr`, `.even`, etc.

## Recipes

```bash
GCC=/opt/amiga/bin/m68k-amigaos-gcc

# CLI binary, KS2.0+, no ixemul dependency, 68000-safe
$GCC -Os -m68000 -noixemul main.c -o main

# Kickstart 1.3 binary
$GCC -Os -m68000 -mcrt=nix13 main.c -o main

# Unix port against clib2
$GCC -Os -m68020 -mcrt=clib2 main.c -o main -lunix -lnet

# Shared library (baserel, small code, libnix4 runtime)
$GCC -Os -m68000 -fbaserel -msmall-code -mcrt=library -ramiga-lib \
     -nostartfiles -o mylib.library libinit.c funcs.c -lamiga

# Resident (ROMable / LoadResident-able) library
$GCC -Os -m68000 -resident -msmall-code -mcrt=library -ramiga-lib \
     -nostartfiles -o mylib.library ...

# Assemble Motorola-syntax .s with vasm (hunk output)
/opt/amiga/bin/vasmm68k_mot -Fhunk -m68020 -o foo.o foo.s

# Inspect a built binary
/opt/amiga/bin/m68k-amigaos-objdump -d -h mylib.library
/opt/amiga/bin/m68k-amigaos-objdump -t prog | grep hunk  # hunk sections
/opt/amiga/bin/ira -M68020 mylib.library                # full disassembly
```

`-g` binaries keep Amiga debug hunks so `m68k-amigaos-gdb` gets symbols/line
info; strip with `m68k-amigaos-strip` for release.

## Library-building pipeline

The NDK flow for publishing a new .library's interface:

1. Write `lib.fd` (function list) — or go straight to `.sfd`.
2. `fd2sfd lib.fd` -> `.sfd`; `sfdc` generates `gatestubs` + proto/inline/clib headers.
3. `fd2pragma` generates `proto/`, `inline/`, `clib/`, `pragmas/` headers directly from `.fd`.
4. `mkstub` builds the link-time stub library (`libfoo.a` with LVO-jump stubs,
   like `libamiga.a`).
5. Library code: `struct Library` base + `LibOpen/LibClose/LibExpunge/LibExtFunc`
   (see `libnix/include/libinit.h`), jump table at negative offsets,
   `-fbaserel -msmall-code` so the lib is relocatable/ROMable.
