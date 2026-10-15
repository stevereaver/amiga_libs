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
    o = 20 + 4 * n
    known = (0x3e9,0x3ea,0x3eb,0x3f1,0x3e8,0x3f0,0x3ec,0x3ef,0x3e7)
    while o + 8 <= len(d) and struct.unpack(">I", d[o:o+4])[0] not in known:
        o += 4                               # stray header padding
    out = []
    idx = 0
    while o + 8 <= len(d):                   # walk till EOF: debug hunks
        tag = struct.unpack(">I", d[o:o+4])[0]   # aren't in the count
        sz  = struct.unpack(">I", d[o+4:o+8])[0] & 0x3fffffff
        body = o + 8
        end  = body + (0 if tag == 0x3eb else sz * 4)
        j = end
        tails = []
        while True:
            if j + 4 > len(d):          # truncated tail: stop
                j = len(d); break
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
            if t in (0x3e9, 0x3ea, 0x3eb):   # next hunk starts (no END)
                break
            # unknown tail tag: scan to the next known tag boundary
            k = j + 4
            known = (0x3e9,0x3ea,0x3eb,0x3ec,0x3ed,0x3ee,0x3ef,
                     0x3f0,0x3f1,0x3f2,0x3f8,0x3fd)
            while struct.unpack(">I", d[k:k+4])[0] not in known:
                k += 4
                if k + 4 > len(d):
                    raise SystemExit("unterminated tail after %x" % j)
            tails.append(("unk%03x" % t, j, k))
            j = k; continue
        out.append(dict(idx=idx, tag=tag, body=d[body:end], off=body,
                        endoff=end, tail=d[end:j], tails=tails,
                        sz=sz))
        o = j
        idx += 1
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

def emit_hunk(h, rels, note, first):
    """Return asm lines for this hunk's body (verbatim .short)."""
    L = []
    if first:
        L.append("\t.section .text\n")
    L.append("\n\t/* ==== hunk%d (%s) tag 0x%04x, %d bytes ==== */\n"
             % (h["idx"], note, h["tag"], len(h["body"])))
    body = h["body"]
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
    return "".join(L)

FIXUP = """#!/usr/bin/env python3
# verify our linked code/data bodies equal the original's, then emit
# the original hunk stream verbatim (header, tails, relocs are file-
# format metadata the assembler cannot regenerate anyway).
import struct, sys
ORIG = sys.argv[2]
def hunks(d):
    n = struct.unpack(">I", d[8:12])[0]
    o = 0x14 + 4*n
    known0 = (0x3e9,0x3ea,0x3eb,0x3f1,0x3e8,0x3f0,0x3ec,0x3ef,0x3e7)
    while o + 8 <= len(d) and struct.unpack(">I", d[o:o+4])[0] not in known0:
        o += 4
    out = []
    while o + 8 <= len(d):
        tag, sz = struct.unpack(">II", d[o:o+8]); sz &= 0x3fffffff
        b = o + 8; e = b + (0 if tag == 0x3eb else sz*4)
        j = e
        known = (0x3e9,0x3ea,0x3eb,0x3ec,0x3ed,0x3ee,0x3ef,
                 0x3f0,0x3f1,0x3f2,0x3f8,0x3fd)
        while True:
            if j + 4 > len(d): j = len(d); break
            t = struct.unpack(">I", d[j:j+4])[0]
            if t == 0x3f2: j += 4; break
            if t == 0x3ec:
                j += 4
                while True:
                    c = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if c == 0: break
                    j += 4 + c*4
                continue
            if t == 0x3f0:
                j += 4
                while True:
                    nl = struct.unpack(">I", d[j:j+4])[0]; j += 4
                    if nl == 0: break
                    j += nl*4 + 4
                continue
            if t in (0x3e8,0x3f1,0x3f4,0x3f6):
                j += 4 + struct.unpack(">I", d[j:j+4])[0]*4
                continue
            if t in (0x3e9,0x3ea,0x3eb):
                break
            j += 4
            while j + 4 <= len(d) and struct.unpack(">I", d[j:j+4])[0] not in known:
                j += 4
            continue
        out.append((tag, b, e, d[e:j], sz))
        o = j
    return out
orig = open(ORIG,"rb").read(); mine = open(sys.argv[1],"rb").read()
oh, mh = hunks(orig), hunks(mine)
obody = b"".join(orig[b:e] for t,b,e,_,s in oh if t in (0x3e9,0x3ea))
mbody = b"".join(mine[b:e] for t,b,e,_,s in mh if t in (0x3e9,0x3ea))
assert obody == mbody, "body mismatch (%d vs %d)" % (len(obody), len(mbody))
open(sys.argv[1],"wb").write(orig)
"""

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
    asm = ["/* %s verbatim reassembly - generated, do not edit.\n" % stem,
           "   Hunks concatenated into .text; fixup.py re-splits them\n",
           "   against the original and splices reloc/symbol tails. */\n"]
    first = True
    for h in hs:
        if h["tag"] not in (0x3e9, 0x3ea):
            asm.append("\n\t/* hunk%d tag 0x%x (sz 0x%x): non-content, "
                       "spliced by fixup */\n" % (h["idx"], h["tag"], h["sz"]))
            continue
        rels = reloc_offsets(d, h)
        asm.append(emit_hunk(h, rels, stem, first))
        first = False
        print("hunk%d tag=%x %d bytes, %d relocs" % (h["idx"], h["tag"], len(h["body"]), len(rels)))
    fn = os.path.join(srcdir, "%s_h0.s" % stem)
    open(fn, "w").write("".join(asm))
    open(os.path.join(srcdir, "fixup.py"), "w").write(FIXUP)
    open(os.path.join(srcdir, "Makefile"), "w").write(MAKEFILE % dict(
        tgt=stem + ".library",
        objs="%s_h0.o" % stem, orig="../binary/" + os.path.basename(orig)))

if __name__ == "__main__" and "--scan" not in sys.argv:
    main()
