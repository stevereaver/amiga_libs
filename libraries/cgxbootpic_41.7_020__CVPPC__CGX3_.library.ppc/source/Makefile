CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/cgxbootpic_41.7(020)(CVPPC)(CGX3).library.ppc
OBJS    = cgxbootpic_41_7_020__CVPPC__CGX3__library_ppc_h0.o

all: cgxbootpic_41_7_020__CVPPC__CGX3__library_ppc.library

cgxbootpic_41_7_020__CVPPC__CGX3__library_ppc.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o cgxbootpic_41_7_020__CVPPC__CGX3__library_ppc.library
