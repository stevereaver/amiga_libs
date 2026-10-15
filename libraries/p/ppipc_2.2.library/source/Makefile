# Makefile for ppipc.library 2.2 reconstruction.
# 11 hunks: h0 code (stub+RomTag+helpers), h1 datatab+sysbase cell,
# h2 strings+functab+InitTable, h3 init+lib vecs, h4 seglist cell,
# h5 port-manager code, h6 BSS port list, h7 broker code, h8 broker
# name, h9 id helpers, h10 exec stubs. fixup.py restores the
# original RELOC32 group order.

CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s

TARGET  = ppipc.library

OBJS = ppipc_h0.o ppipc_h1.o ppipc_h2.o ppipc_h3.o ppipc_h4.o ppipc_h5.o \
       ppipc_h6.o ppipc_h7.o ppipc_h8.o ppipc_h9.o ppipc_h10.o

all: $(TARGET)

$(TARGET): $(OBJS) fixup.py
	printf 'SECTIONS { .h0 : { ppipc_h0.o(.text) } .h1 : { ppipc_h1.o(.data) } .h2 : { ppipc_h2.o(.data) } .h3 : { ppipc_h3.o(.text) } .h4 : { ppipc_h4.o(.data) } .h5 : { ppipc_h5.o(.text) } .h6 : { ppipc_h6.o(.bss) } .h7 : { ppipc_h7.o(.text) } .h8 : { ppipc_h8.o(.data) } .h9 : { ppipc_h9.o(.text) } .h10 : { ppipc_h10.o(.text) } }\n' > hunks.x
	$(CC) $(LDFLAGS) -Wl,-T,hunks.x -o $(TARGET) $(OBJS)
	python3 fixup.py $(TARGET)

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o $(TARGET)

.PHONY: all clean
