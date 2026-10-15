CC = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS = -m68000 -O2 -ffixed-a5 -nostdlib -nostartfiles -fno-builtin -fno-ipa-icf

all: genesiskey.library

genesiskey_lib.o: genesiskey_lib.s
	$(CC) -m68000 -c -o $@ $<

endmodule.o: endmodule.s
	$(CC) -m68000 -c -o $@ $<

genesiskey.o: genesiskey.c
	$(CC) $(CFLAGS) -c -o $@ $<

genesiskey.library: genesiskey_lib.o genesiskey.o endmodule.o
	$(CC) -nostdlib -nostartfiles -o $@ genesiskey_lib.o genesiskey.o endmodule.o

clean:
	rm -f *.o genesiskey.library

.PHONY: all clean
