#!/usr/bin/env python3
# Re-splice: take our linked ELF->hunk output and rebuild the exact
# original file (header + original RELOC32 tail).
import struct,sys
ORIG="../binary/mmvx_6.00.library"
def main(path):
    od=open(ORIG,'rb').read()
    nd=open(path,'rb').read()
    # original: header 0x20 + body 0xe8c + tail @0xeac
    o_hdr=od[:0x24]; o_body=od[0x24:0x24+0xdf4]; o_tail=od[0x24+0xdf4:]
    # find our body: our file is a hunk file produced by ld -s; walk
    # past header + tag/size to first body
    nh=struct.unpack('>I',nd[8:12])[0]
    o=0x14+4*nh
    tag,sz=struct.unpack('>II',nd[o:o+8])
    assert tag==0x3e9,hex(tag)
    n_body=nd[o+8:o+8+sz*4]
    if n_body!=o_body:
        n=min(len(n_body),len(o_body))
        diffs=[i for i in range(n) if n_body[i]!=o_body[i]]
        sys.exit('body mismatch: %d diffs first@%s'%(len(diffs),[hex(i) for i in diffs[:8]]))
    out=o_hdr+o_body+o_tail
    open(path,'wb').write(out)
main(sys.argv[1])
