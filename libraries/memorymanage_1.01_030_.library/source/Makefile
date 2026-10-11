CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68030
CFLAGS  = -m68030 -O2 -ffixed-a5 -nostdlib -nostartfiles -fno-builtin
LDFLAGS = -nostdlib -nostartfiles

TARGET  = memorymanage.library

all: $(TARGET)

$(TARGET): memorymanage_lib.o memorymanage.o
	$(CC) $(LDFLAGS) -o $@ memorymanage_lib.o memorymanage.o

memorymanage_lib.o: memorymanage_lib.s
	$(CC) $(ASFLAGS) -c -o $@ memorymanage_lib.s

memorymanage.o: memorymanage.c
	$(CC) $(CFLAGS) -c -o $@ memorymanage.c

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean
