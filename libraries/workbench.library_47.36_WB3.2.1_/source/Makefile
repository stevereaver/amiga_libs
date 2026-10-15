CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/workbench.library_47.36(WB3.2.1)
OBJS    = workbench_library_47_36_WB3_2_1__h0.o

all: workbench_library_47_36_WB3_2_1_.library

workbench_library_47_36_WB3_2_1_.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o workbench_library_47_36_WB3_2_1_.library
