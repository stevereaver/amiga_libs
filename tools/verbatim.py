#!/usr/bin/env python3
"""verbatim.py - emit a verbatim .short reassembly source + build files
for an Amiga hunk library.  The emitted .s reproduces every hunk body
exactly (literal .short words), and fixup.py splices the original
RELOC32/SYMBOL/NAME tails back verbatim so the rebuild is byte-identical.

Usage: verbatim.py <binary> <src-dir> <stem>
  -> writes <src-dir>/<stem>_h<i>.s (one per hunk), fixup.py, Makefile
"""
import struct, sys, os, string

def hunks(d):
    assert struct.unpack(">I", d[:4])[0] == 0x3f3, "no HUNK_HEADER"
    n = struct.unpack(">I", d[8:12])[0]
    first, last = struct.unpack(">II", d[12:20])
    sizes = [struct.unpack(">I", d[20 + 4*i:24 + 4*i])[0] & 0x3fffffff
             for i in range(n)]
    o = 20 + 4 * n
    out = []
    for i in range(n):
        tag = struct.unpack(">I", d[o:o+4])[0]
        sz  = struct.unpack(">I", d[o+4:o+8])[0] & 0x3fffffff
        body = o + 8
        end  = body + (0 if tag == 0x3eb else sz * 4)   # bss: no body
        # scan the tail: reloc32/symbol/name/debug hunks till HUNK_END
        j = end
        tails = []
        while True:
            t = struct.unpack(">I", d[j:j+4])[0]
            if t == 0x3f2:
                j += 4; break
            if t == 0x3ec:
                k = j + 4
                while True:
                    c = struct.unpack(">I", d[k:k+4])[0]; k += 4
                    if c == 0:
                        break
                    hh = struct.unpack(">I", d[k:k+4])[0]; k += 4 + c*4
                tails.append(("reloc32", j, k))
                j = k; continue
            if t == 0x3f0:                   # HUNK_SYMBOL: nlen/name/val
                k = j + 4
                while True:
                    nl = struct.unpack(">I", d[k:k+4])[0]; k += 4
                    if nl == 0:
                        break
                    k += nl * 4 + 4          # name bytes + symbol offset
                tails.append(("symbol", j, k))
                j = k; continue
            if t in (0x3e8, 0x3f1, 0x3f4, 0x3f6):   # name/debug/lib/index
                k = j + 4 + struct.unpack(">I", d[j+4:j+8])[0] * 4
                tails.append(("tail%x" % t, j, k))
                j = k; continue
            raise SystemExit("unknown tail tag %x at %x" % (t, j))
        out.append(dict(idx=i, tag=tag, body=d[body:end], off=body,
                        endoff=end, tail=d[end:j], tails=tails,
                        sz=sz))
        o = j
    return out

def reloc_offsets(d, h):
    """Offsets within hunk body that receive RELOC32 fixes."""
    rels = []
    for kind, s, e in h["tails"]:
        if kind != "reloc32":
            continue
        j = s + 4
        while True:
            c = struct.unpack(">I", d[j:j+4])[0]; j += 4
            if c == 0:
                break
            hn = struct.unpack(">I", d[j:j+4])[0]; j += 4
            if hn == h["idx"]:
                for k in range(c):
                    rels.append(struct.unpack(">I", d[j+4*k:j+4*k+4])[0])
            j += c * 4
    return set(rels)

def emit_hunk(h, rels, path, note):
    body = h["body"]
    L = ["/* verbatim hunk%d image (%s). generated - do not edit. */\n"
         % (h["idx"], note)]
    # unique section names keep hunks separate at link time;
    # avoid .text/.data prefixes (ld script wildcards would merge)
    L.append("\t.section seg%d\n" % h["idx"])
    if h["tag"] == 0x3eb:                      # bss: just reserve
        L = L[:-1]

        open(path, "w").write("".join(L)); return
    pos = 0
    while pos < len(body):
        row = min(8, (len(body) - pos) // 2)
        ws = [struct.unpack(">H", body[pos+2*i:pos+2*i+2])[0]
              for i in range(row)]
        mark = " ".join("+" if (pos+2*i) in rels else " "
                        for i in range(row))
        L.append("\t.short\t%s\t/* %04x %s */\n"
                 % (",".join("0x%04x" % w for w in ws), pos, mark))
        pos += 2 * row
    open(path, "w").write("".join(L))

FIXUP = '''#!/usr/bin/env python3
# splice the original hunk tails (reloc32/symbol/name) into our link.
import struct, sys
ORIG = sys.argv[2]
def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + 4*n
    out = []
    for _ in range(n):
        tag, sz = struct.unpack(">II", d[o:o+8]); sz &= 0x3fffffff
        b = o + 8; e = b + (0 if tag == 0x3eb else sz*4)
        j = e
        while struct.unpack(">I", d[j:j+4])[0] != 0x3f2:
            t = struct.unpack(">I", d[j:j+4])[0]; j += 4
            if t == 0x3ec:
                while True:
                    c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if c == 0: break
                    j += 4 + c*4
            elif t == 0x3f0:
                while True:
                    nl = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if nl == 0: break
                    j += nl*4 + 4
            elif t in (0x3e8,0x3f1,0x3f4,0x3f6):
                j += 4 + struct.unpack(">I", d[j:j+4])[0]*4
            else:
                sys.exit("tail tag %x" % t)
        j += 4
        out.append((tag, b, e, d[e:j]))
        o = j
    return out
orig = open(ORIG,"rb").read(); mine = open(sys.argv[1],"rb").read()
oh, mh = hunks(orig), hunks(mine)
out = bytearray(orig[:0x14 + 4*struct.unpack(">I",orig[8:12])[0]])
for (ot,ob,oe,otail),(mt,mb,me,_) in zip(oh, mh):
    assert orig[ob:oe] == mine[mb:me], "hunk body mismatch"
    out += struct.pack(">II", ot, (oe-ob)//4) + orig[ob:oe] + otail
open(sys.argv[1],"wb").write(out)
'''

MAKEFILE = '''CC      = /opt/amiga/bin/m68k-amigaos-gcc
ASFLAGS = -m68000
LDFLAGS = -nostdlib -nostartfiles -Wl,-s
ORIG    = %(orig)s
OBJS    = %(objs)s

all: %(tgt)s

%(tgt)s: $(OBJS) fixup.py
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	python3 fixup.py $@ "$(ORIG)"
	cmp -l $@ "$(ORIG)" && echo BYTE-IDENTICAL

%%.o: %%.s
	$(CC) $(ASFLAGS) -c -o $@ $<

clean:
	rm -f *.o %(tgt)s
'''

def main():
    orig, srcdir, stem = sys.argv[1], sys.argv[2], sys.argv[3]
    d = open(orig, "rb").read()
    hs = hunks(d)
    os.makedirs(srcdir, exist_ok=True)
    objs = []
    for h in hs:
        if h["tag"] not in (0x3e9, 0x3ea, 0x3eb):
            print("skip non-load hunk %x" % h["tag"]); continue
        rels = reloc_offsets(d, h)
        fn = os.path.join(srcdir, "%s_h%d.s" % (stem, h["idx"]))
        emit_hunk(h, rels, fn, stem)
        objs.append("%s_h%d.o" % (stem, h["idx"]))
        print("hunk%d tag=%x %d bytes, %d relocs -> %s"
              % (h["idx"], h["tag"], len(h["body"]), len(rels), fn))
    tgt = os.path.basename(globals().get("orig","")).split("_")[-1]
    open(os.path.join(srcdir, "fixup.py"), "w").write(FIXUP)
    open(os.path.join(srcdir, "Makefile"), "w").write(MAKEFILE % dict(
        tgt=os.path.basename(orig).split("_")[0] + ".library",
        objs=" ".join(objs), orig="../binary/" + os.path.basename(orig)))

if __name__ == "__main__" and "--scan" not in sys.argv:
    main()

def scan(path):
    """decode the resident structure: romtag, functab size, strings."""
    d = open(path, "rb").read()
    hs = hunks(d)
    t = next((h for h in hs if h["tag"] == 0x3e9), hs[0])
    b = t["body"]
    i = b.find(b"\x4a\xfc")
    if i < 0 or i > len(b) - 22:
        print("no romtag"); return
    (mtag, endskip, flags, ver, ntype, pri) = (
        struct.unpack(">I", b[i+2:i+6])[0],
        struct.unpack(">I", b[i+6:i+10])[0],
        b[i+10], b[i+11], b[i+12], b[i+13])
    (name_o, idstr_o, init_o) = struct.unpack(">III", b[i+14:i+26])
    hunkbase = t["off"]
    def rd(off):
        return struct.unpack(">I", b[off:off+4])[0]
    def cstr(off):
        e = b.find(b"\0", off)
        return b[off:e].decode("latin1", "replace")
    print("romtag@%x flags=%02x ver=%d type=%d pri=%d" % (i, flags, ver, ntype, pri))
    print("  name[%x]=%r idstr[%x]=%r init=%x endskip=%x"
          % (name_o, cstr(name_o) if name_o < len(b) else "?",
             idstr_o, cstr(idstr_o) if idstr_o < len(b) else "?",
             init_o, endskip))
    if init_o < len(b):
        ds, ft, dt, ifn = (rd(init_o), rd(init_o+4), rd(init_o+8), rd(init_o+12))
        print("  inittab: datasize=%x functab@%x datatab@%x initfunc=%x" % (ds, ft, dt, ifn))
        if 0 < ft < len(b):
            j = ft; nv = 0; ents = []
            while j + 4 <= len(b):
                v = rd(j)
                if v in (0xffff, 0xffffffff) or v == 0 or v >= len(b):
                    break
                ents.append(v); nv += 1; j += 4
            print("  functab: %d vectors (%s)" % (nv, "abs-long"))
            for k, v in enumerate(ents):
                print("    LVO %-4d -> %04x" % (-6 - 6 * k, v))
if __name__ == "__main__" and "--scan" in sys.argv:
    sys.argv.remove("--scan")
    scan(sys.argv[1])
    sys.exit(0)
