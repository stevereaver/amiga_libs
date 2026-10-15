CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/rexxsyslib_36.23(WB2.04+).library
OBJS    = rexxsyslib_36_23_WB2_04___h0.o rexxsyslib_36_23_WB2_04___h1.o

all: rexxsyslib.library

rexxsyslib.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o rexxsyslib.library
