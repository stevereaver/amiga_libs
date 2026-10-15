CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/rexxplslib_1.Q199310230407.library
OBJS    = rexxplslib_1_Q199310230407_h0.o rexxplslib_1_Q199310230407_h1.o rexxplslib_1_Q199310230407_h2.o

all: rexxplslib.library

rexxplslib.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o rexxplslib.library
