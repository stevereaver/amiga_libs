CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/netcrypt_1.0-alt2.library
OBJS    = netcrypt_1_0_alt2_h0.o netcrypt_1_0_alt2_h1.o netcrypt_1_0_alt2_h2.o

all: netcrypt.library

netcrypt.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o netcrypt.library
