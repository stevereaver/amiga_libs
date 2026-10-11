CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
CFLAGS  = -m68000 -O2 -nostdlib -nostartfiles -fno-builtin
LDFLAGS = -nostdlib -nostartfiles

TARGET  = ted.library

all: $(TARGET)

$(TARGET): ted_lib.o ted.o
	$(CC) $(LDFLAGS) -o $@ ted_lib.o ted.o

ted_lib.o: ted_lib.s
	$(CC) $(ASFLAGS) -c -o $@ ted_lib.s

ted.o: ted.c
	$(CC) $(CFLAGS) -c -o $@ ted.c

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean
