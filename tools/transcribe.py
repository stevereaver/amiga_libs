#!/usr/bin/env python3
"""transcribe.py <binary> <hunk_body_off> <hunk_body_len> <out.s> [cpu]

Byte-verbatim gas source for a hunk body: real mnemonics where gas
reproduces the encoding; L<hex> labels at in-range branch/pc-rel
targets; .byte for data spans/objdump gaps/inner-label spans;
.short for mem-indirect pc@()@(), absolute-memory operands, immediate
forms gas canonicalizes, and any operand referencing outside the hunk.
"""
import re, subprocess, sys

binpath, boff, blen, outs = sys.argv[1], int(sys.argv[2],0), int(sys.argv[3],0), sys.argv[4]
cpu = sys.argv[5] if len(sys.argv)>5 else 'm68k:68020'
code = open(binpath,'rb').read()[boff:boff+blen]
tmp = outs + '.bin'
open(tmp,'wb').write(code)
dis = subprocess.run(['/opt/amiga/bin/m68k-amigaos-objdump','-b','binary','-m',cpu,'-D',tmp,'--adjust-vma=0'],
                     capture_output=True,text=True).stdout.splitlines()
tok=[]
for L in dis:
    m=re.match(r'\s*([0-9a-f]+):\t([0-9a-f ]+?)\s*\t(.*)',L)
    if m and m.group(2).strip(): tok.append((int(m.group(1),16),bytes.fromhex(m.group(2).replace(' ','')),m.group(3).strip() or None)); continue
    m=re.match(r'\s*([0-9a-f]+):\t([0-9a-f ]+?)\s*$',L)
    if m and m.group(2).strip(): tok.append((int(m.group(1),16),bytes.fromhex(m.group(2).replace(' ','')),None))
full=[]; pos=0
for a,b,t in tok:
    if a>pos: full.append((pos,code[pos:a],None))
    full.append((a,b,t)); pos=max(pos,a+len(b))
if pos<len(code): full.append((pos,code[pos:],None))
tok=full
targets=set()
for a,b,t in tok:
    if not t: continue
    for m in re.finditer(r'%pc@\(0x([0-9a-f]+)\)',t): targets.add(int(m.group(1),16))
    m=re.match(r'(b\w+|bsr|bra|db\w+)\w*\s+(0x[0-9a-f]+)\s*$',t)
    if m: targets.add(int(m.group(2),16))
REGS={'d0','d1','d2','d3','d4','d5','d6','d7','a0','a1','a2','a3','a4','a5','a6','a7','w','l','b','sp','pc','sr','usp','vbr','cacr','pcr','tc','srp','crp','dtt0','dtt1','itt0','itt1','isp','msp','mmusr','urp','fp0','fp1','fp2','fp3','fp4','fp5','fp6','fp7','fpcr','fpsr','fpiar','ccr'}
def fixops(t):
    def fix(m):
        parts=re.split(r'([,:])',m.group(1))
        parts=['0x'+p if (re.fullmatch(r'[0-9a-f]+',p) and re.search(r'[a-f]',p) and p not in REGS) else p for p in parts]
        return '@('+''.join(parts)+')'
    return re.sub(r'@\(([^)]*)\)',fix,t)
out=['\t.text']
i=0
while i<len(tok):
    a,b,t=tok[i]
    j=i+1
    while j<len(tok) and tok[j][2] is None and tok[j][0]==a+len(b):
        b+=tok[j][1]; j+=1
    end=a+len(b)
    inner=sorted(x for x in targets if a<x<end)
    if a in targets: out.append('L%x:'%a)
    if t is None or inner or j>i+1:
        pos=0
        for x in inner:
            out.append('\t.byte '+','.join('0x%02x'%c for c in b[pos:x-a])); out.append('L%x:'%x); pos=x-a
        out.append('\t.byte '+','.join('0x%02x'%c for c in b[pos:])+(('\t/* '+t+' */') if t else ''))
        i=j; continue
    oob=[False]
    def pcrel(m):
        if int(m.group(1),16)<len(code): return '%'+'pc@(L%s)'%m.group(1)
        oob[0]=True; return m.group(0)
    t2=re.sub(r'%pc@\(0x([0-9a-f]+)\)',pcrel,t)
    m=re.match(r'(b\w+|bsr|bra|db\w+)(\w*)\s+(0x[0-9a-f]+)\s*$',t2)
    if m:
        tg=int(m.group(3),16)
        if tg<len(code): t2='%s%s L%x'%(m.group(1),m.group(2),tg)
        else: oob[0]=True
    memind = (t2.count('@(')>1 and 'pc@' in t2) or ('%pc@(' in t2 and ',' in t2.split('%pc@(')[1].split(')')[0])
    absmem = bool(re.match(r'(lea|jsr|jmp|pea)\s+0x[0-9a-f]+',t2)) or bool(re.search(r',\s*0x[0-9a-f]+\s*$',t2) and 'pc@' not in t2 and not t2.startswith('movel #') and not t2.startswith('cmp'))
    immform = bool(re.match(r'(ori|or|andi|and|eori|eor|addi|add|subi|sub|cmpi|cmp|move)\w*\s+#',t2))
    if oob[0] or memind or absmem or immform:
        out.append('\t.short '+','.join('0x%02x%02x'%(b[k],b[k+1]) for k in range(0,len(b),2))+'\t/* '+t+' */')
    else:
        out.append('\t'+fixops(t2))
    i=j
open(outs,'w').write('\n'.join(out)+'\n')
