CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
CFLAGS  = -m68000 -O2 -ffixed-a5 -nostdlib -nostartfiles -fno-builtin
LDFLAGS = -nostdlib -nostartfiles

TARGET  = cachefile.library

all: $(TARGET)

$(TARGET): cachefile_lib.o cachefile.o
	$(CC) $(LDFLAGS) -o $@ cachefile_lib.o cachefile.o

cachefile_lib.o: cachefile_lib.s
	$(CC) $(ASFLAGS) -c -o $@ cachefile_lib.s

cachefile.o: cachefile.c
	$(CC) $(CFLAGS) -c -o $@ cachefile.c

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean
