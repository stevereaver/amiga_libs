CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = ../binary/info_1.31(WB1.3).library
OBJS    = info_1_31_WB1_3__h0.o info_1_31_WB1_3__h1.o info_1_31_WB1_3__h2.o info_1_31_WB1_3__h3.o info_1_31_WB1_3__h4.o info_1_31_WB1_3__h5.o info_1_31_WB1_3__h6.o info_1_31_WB1_3__h7.o info_1_31_WB1_3__h8.o info_1_31_WB1_3__h9.o info_1_31_WB1_3__h10.o info_1_31_WB1_3__h11.o info_1_31_WB1_3__h12.o info_1_31_WB1_3__h13.o info_1_31_WB1_3__h14.o info_1_31_WB1_3__h15.o info_1_31_WB1_3__h16.o info_1_31_WB1_3__h17.o info_1_31_WB1_3__h18.o info_1_31_WB1_3__h19.o info_1_31_WB1_3__h20.o info_1_31_WB1_3__h21.o info_1_31_WB1_3__h22.o info_1_31_WB1_3__h23.o info_1_31_WB1_3__h24.o

all: info.library

info.library: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%.o: %.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o info.library
