# Makefile for geclass.library 37.6 reconstruction.
# Two hunks: h0 CODE (RomTag+InitTable+6-vector functab+code+data tail),
# h1 BSS (0xc0 bytes of library-private state).
# fixup.py rewrites hunk0's RELOC32 records to the original group
# order (16 self refs descending, then 7 hunk1 refs ascending) and
# converts hunk1 to a body-less HUNK_BSS.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = geclass.library
OBJS    = geclass_h0.o geclass_h1.o

all: $(TARGET)

$(TARGET): $(OBJS) fixup.py
	printf 'SECTIONS { .h0 : { geclass_h0.o(.text) } .h1 : { geclass_h1.o(.bss) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) $(OBJS)
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o hunks.x $(TARGET)

.PHONY: all clean
