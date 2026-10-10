# Makefile for xpkRLEN.library 1.1 C reconstruction
#
# Two-hunk SAS/C-style build (CODE + DATA).  The DATA hunk
# carries the descriptor template INITFUNCTION copies to
# base+58; FUNCTABLE is the long-address format (no
# genfunctab pass needed).

CC      = /opt/amiga/bin/m68k-amigaos-gcc
CFLAGS  = -O2 -m68000 -fomit-frame-pointer -fno-builtin \
          -I/opt/amiga/m68k-amigaos/ndk-include \
          -Wall -Wno-unused-parameter
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles

TARGET  = xpkRLEN.library

all: $(TARGET)

$(TARGET): xpkrlen_lib.o xpkrlen.o endmodule.o
	$(CC) $(LDFLAGS) -o $@ xpkrlen_lib.o xpkrlen.o endmodule.o

xpkrlen_lib.o: xpkrlen_lib.s
	$(CC) $(ASFLAGS) -c -o $@ xpkrlen_lib.s

endmodule.o: endmodule.s
	$(CC) $(ASFLAGS) -c -o $@ endmodule.s

xpkrlen.o: xpkrlen.c
	$(CC) $(CFLAGS) -c -o $@ xpkrlen.c

clean:
	rm -f *.o *.nm functab.s dummy.library $(TARGET)

.PHONY: all clean
