CC=/opt/amiga/bin/m68k-amigaos-gcc
CFLAGS=-m68020 -nostdlib -nostartfiles

all: SysInfo.library

SysInfo.library: SysInfo_h0.o
	$(CC) $(CFLAGS) -o $@ $<
	python3 fixup.py $@
	cmp $@ ../binary/SysInfo_2.00.library && echo BYTE-IDENTICAL

SysInfo_h0.o: SysInfo_h0.s
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o SysInfo.library

.PHONY: all clean
