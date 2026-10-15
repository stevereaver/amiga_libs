CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: sysinfo.library

sysinfo.library: sysinfo_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/sysinfo_1.30.library && echo BYTE-IDENTICAL

sysinfo_h0.o: sysinfo_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o sysinfo.library

.PHONY: all clean
