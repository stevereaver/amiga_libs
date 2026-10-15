CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/asl.library_47.9(WB3.2.1)
OBJS    = asl_library_47_9_WB3_2_1__h0.o

all: asl_library_47_9_WB3_2_1_.library

asl_library_47_9_WB3_2_1_.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o asl_library_47_9_WB3_2_1_.library
