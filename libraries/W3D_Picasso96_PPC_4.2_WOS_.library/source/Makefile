CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/W3D_Picasso96_PPC_4.2(WOS).library
OBJS    = W3D_Picasso96_PPC_4_2_WOS__h0.o W3D_Picasso96_PPC_4_2_WOS__h1.o W3D_Picasso96_PPC_4_2_WOS__h2.o W3D_Picasso96_PPC_4_2_WOS__h3.o W3D_Picasso96_PPC_4_2_WOS__h4.o W3D_Picasso96_PPC_4_2_WOS__h5.o

all: W3D.library

W3D.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o W3D.library
