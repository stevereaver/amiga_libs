CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/info_1.1(WB1.1).library
OBJS    = info_1_1_WB1_1__h0.o info_1_1_WB1_1__h1.o info_1_1_WB1_1__h2.o info_1_1_WB1_1__h3.o info_1_1_WB1_1__h4.o info_1_1_WB1_1__h5.o info_1_1_WB1_1__h6.o info_1_1_WB1_1__h7.o info_1_1_WB1_1__h8.o info_1_1_WB1_1__h9.o info_1_1_WB1_1__h10.o info_1_1_WB1_1__h11.o info_1_1_WB1_1__h12.o info_1_1_WB1_1__h13.o info_1_1_WB1_1__h14.o info_1_1_WB1_1__h15.o info_1_1_WB1_1__h16.o info_1_1_WB1_1__h17.o info_1_1_WB1_1__h18.o info_1_1_WB1_1__h19.o info_1_1_WB1_1__h20.o info_1_1_WB1_1__h21.o info_1_1_WB1_1__h22.o info_1_1_WB1_1__h23.o info_1_1_WB1_1__h24.o

all: info.library

info.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o info.library
