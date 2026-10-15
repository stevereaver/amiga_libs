#!/usr/bin/env python3
# oracle.py -- run rexxsupport_34.9.library (original or rebuild)
# under machine68k.
#
# The library has 5 vectors: Open(-6) Close(-12) Expunge(-18)
# Null(-24) Dispatch(-30).  Dispatch decodes a packed name table and
# runs one of 23 ARexx functions against a request block:
#   rq+20 -> task block T; T+136 = result buffer
#   rq+31  = arg count (excluding name)
#   rq+40  = name argstring ptr (header at -8: [size][len][0x46][ck])
#   rq+44+ = arg argstring ptrs
#   rq+364 = internal port-list head (GETPKT/WAITPKT/OPENPORT/...)
#   rq+283 = caller signal byte for WAITPKT
# Result: d0 = error code, a0 = result argstring or 0.
#
# Stubs model exec (-132..-552), dos.library vectors used by the
# doscall shim (-72,-78,-84,-90,-102,-108,-120,-198), and the
# rexxsyslib internals the code calls (-126,-132,-174,-180,-186,
# -192,-198,-204,-210,-222,-288,-294,-306,-312,-474).
#
# Stored offsets in the hunk count from code+0 (RELBASE=0).

import struct, sys, os
sys.path.insert(0, os.path.dirname(__file__))
from machine68k import Machine, CPUType, Register

TRAPBASE = 0xA000

# ---- configuration knobs ----------------------------------------
OPEN_OK   = True          # rexxsyslib.library opens
ALLOC_OK  = True          # exec AllocMem succeeds
LOCKABLE  = True          # dos Lock succeeds
DOSRES    = -1            # default result for DeleteFile/Rename/Delay
DOSRES_MAP = {}           # per-LVO overrides
FIB_ISDIR = True          # Examine's fib_DirEntryType >= 0
EXAM_OK   = True          # Examine returns true
EXNEXT    = []            # queued ExNext entries (dir listing)
FINDPORT  = True          # exec FindPort succeeds for OPENPORT
WAITRET   = 0xffffffff    # value returned by exec Wait (all signals)
PORTQUEUE = []            # msgs pre-queued on the created/found port
RXS198_OK = True          # rxs -198 port-node create succeeds
RXS174_OK = True          # rxs -174 append-node succeeds
VALCONV   = {}            # -474 overrides: str -> (status, value)

def load(binpath, relbase=0):
    CODE=[0x40000,0x70000,0x80000,0x90000]; LIB=0x100000; SYSB=0x1000
    RXSB=0x50000; DOSB=0x6e000
    ENDTRAP=0x7f0; POOLBASE=[0x300000]
    m = Machine(CPUType.M68020, 32*1024)
    mem, cpu = m.mem, m.cpu
    d = open(binpath,'rb').read()
    nh = struct.unpack('>I', d[0x10:0x14])[0]+1
    o = 0x14 + 4*nh
    hunks=[]
    for i in range(nh):
        tag = struct.unpack('>I', d[o:o+4])[0]; o+=4
        sz  = struct.unpack('>I', d[o:o+4])[0]&0x3fffffff; o+=4
        if (tag & 0x3fffffff) == 0x3eb:
            body = b'\x00'*(sz*4)
        else:
            body = d[o:o+sz*4]; o+=sz*4
        rels=[]
        while True:
            t = struct.unpack('>I', d[o:o+4])[0]; o+=4
            if t == 0x3ec:
                while True:
                    n = struct.unpack('>I', d[o:o+4])[0]; o+=4
                    if n==0: break
                    hn = struct.unpack('>I', d[o:o+4])[0]; o+=4
                    for j in range(n):
                        rels.append((hn, struct.unpack('>I',d[o:o+4])[0])); o+=4
            elif t == 0x3f2: break
            elif t == 0x3f0:
                while True:
                    n = struct.unpack('>I', d[o:o+4])[0]; o+=4
                    if n==0: break
                    o += n*4 + 4
            elif t in (0x3e8,0x3f1,0x3e7,0x3ef):
                n = struct.unpack('>I', d[o:o+4])[0]; o += 4 + n*4
            else:
                print('unknown hunk tag %x at %x' % (t,o)); break
        hunks.append((body, rels))
    for i,(body,rels) in enumerate(hunks): mem.w_block(CODE[i], body)
    for i,(body,rels) in enumerate(hunks):
        for hn,off in rels:
            mem.w32(CODE[i]+relbase+off, mem.r32(CODE[i]+relbase+off)+CODE[hn]+relbase)
    mem.w32(4, SYSB)

    class Done(Exception): pass
    def endtrap(op,pc): raise Done()
    etid = m.traps.alloc(endtrap); mem.w16(ENDTRAP, TRAPBASE|etid)

    LOG=[]
    def stub(at,f):
        tid=m.traps.alloc(f); mem.w16(at,TRAPBASE|tid); mem.w16(at+2,0x4e75)

    def setz(cpu, z):
        """leave the 68k Z flag (SR bit2) as the callee would have."""
        sr = cpu.r_sr()
        cpu.w_sr((sr | 4) if z else (sr & ~4))

    def cstr(a):
        s=b''
        while a and mem.r8(a): s+=bytes([mem.r8(a)]); a+=1
        return s

    def mkarg(s, at=None):
        """write a real argstring: [size][len][0x46][cksum][data]"""
        if at is None:
            at=POOLBASE[0]; POOLBASE[0]+=(len(s)+16)&~3
        mem.w32(at,len(s)+9); mem.w16(at+4,len(s))
        mem.w8(at+6,0x46); mem.w8(at+7,sum(s)&0xff)
        mem.w_block(at+8,s+b'\x00')
        return at+8
    def rdarg(a):
        if not a: return None
        ln=mem.r16(a-4)&0xffff
        return bytes(mem.r_block(a, ln))

    # ---------------- exec -----------------------------------------
    def tr_forbid(op,pc):
        LOG.append(('forbid',)); mem.w8(SYSB+295,(mem.r8(SYSB+295)+1)&0xff)
    def tr_permit(op,pc):
        LOG.append(('permit',)); mem.w8(SYSB+295,(mem.r8(SYSB+295)-1)&0xff)
    def tr_allocmem(op,pc):
        sz=cpu.r_reg(Register.D0); fl=cpu.r_reg(Register.D1)
        at=POOLBASE[0] if ALLOC_OK else 0
        if at: POOLBASE[0]+=(sz+3)&~3; mem.w_block(at,b'\x00'*min(sz,16))
        LOG.append(('allocmem',sz,fl,at))
        cpu.w_reg(Register.D0,at); setz(cpu, at==0)
    def tr_freemem(op,pc):
        LOG.append(('freemem',cpu.r_reg(Register.A1),cpu.r_reg(Register.D0)))
    def tr_addtail(op,pc):
        l=cpu.r_reg(Register.A0); n=cpu.r_reg(Register.A1)
        mem.w32(n, l+4)                 # node.succ = &lh_Tail
        mem.w32(n+4, mem.r32(l+8))      # node.pred = lh_TailPred
        mem.w32(mem.r32(l+8), n)        # tailpred.succ = node
        mem.w32(l+8, n)                 # lh_TailPred = node
        LOG.append(('addtail',l,n))
    def tr_remove(op,pc):
        a=cpu.r_reg(Register.A1)
        s=mem.r32(a); p=mem.r32(a+4)
        if p: mem.w32(p,s)
        if s: mem.w32(s+4,p)
        LOG.append(('remove',a))
    def tr_findname(op,pc):
        a0=cpu.r_reg(Register.A0); nm=cstr(cpu.r_reg(Register.A1))
        n=mem.r32(a0); r=0
        while n:
            if cstr(mem.r32(n+10))==nm: r=n; break
            n=mem.r32(n)
        LOG.append(('findname',a0,nm,r))
        cpu.w_reg(Register.D0,r); setz(cpu, r==0)
    def tr_wait(op,pc):
        mk=cpu.r_reg(Register.D0); LOG.append(('wait',mk))
        cpu.w_reg(Register.D0, WAITRET & 0xffffffff); setz(cpu, WAITRET==0)
    def tr_putmsg(op,pc):
        LOG.append(('putmsg',cpu.r_reg(Register.A0),cpu.r_reg(Register.A1)))
    def tr_getmsg(op,pc):
        p=cpu.r_reg(Register.A0)      # port: msg list at +20 (1.x layout)
        n=mem.r32(p+20)
        if n:
            mem.w32(p+20, mem.r32(n))     # head = head.succ
            if mem.r32(n)==0: mem.w32(p+28, p+20)  # empty -> tailpred=head
        LOG.append(('getmsg',p,n)); cpu.w_reg(Register.D0,n); setz(cpu, n==0)
    def tr_replymsg(op,pc):
        LOG.append(('replymsg',cpu.r_reg(Register.A1)))
    def tr_findport(op,pc):
        nm=cstr(cpu.r_reg(Register.A1)); LOG.append(('findport',nm))
        r=0x72000 if FINDPORT else 0
        cpu.w_reg(Register.D0, r); setz(cpu, r==0)
    def tr_closelib(op,pc):
        LOG.append(('closelib',cpu.r_reg(Register.A1)))
    def tr_openlib(op,pc):
        nm=cstr(cpu.r_reg(Register.A1)); v=cpu.r_reg(Register.D0)
        LOG.append(('openlib',nm,v))
        if nm==b'rexxsyslib.library': r = RXSB if OPEN_OK else 0
        elif nm==b'dos.library':      r = DOSB if OPEN_OK else 0
        else: r = 0
        cpu.w_reg(Register.D0, r); setz(cpu, r==0)

    # ---------------- dos.library ----------------------------------
    def dostr(lvo):
        nm=cstr(cpu.r_reg(Register.D1)); extra=cpu.r_reg(Register.D2)
        r=DOSRES_MAP.get(lvo, DOSRES)
        LOG.append(('dos%d'%(-lvo),nm,extra,r))
        cpu.w_reg(Register.D0, r & 0xffffffff); setz(cpu, r==0)
    def tr_dos72(op,pc): dostr(-72)
    def tr_dos78(op,pc): dostr(-78)
    def tr_dos120(op,pc): dostr(-120)
    def tr_dos198(op,pc):
        LOG.append(('delay',cpu.r_reg(Register.D1)))
        cpu.w_reg(Register.D0, DOSRES & 0xffffffff); setz(cpu, DOSRES==0)
    def tr_lock(op,pc):
        nm=cstr(cpu.r_reg(Register.D1)); md=cpu.r_reg(Register.D2)
        r=0x71000 if LOCKABLE else 0
        LOG.append(('lock',nm,md,r)); cpu.w_reg(Register.D0,r); setz(cpu, r==0)
    def tr_unlock(op,pc):
        LOG.append(('unlock',cpu.r_reg(Register.D1)))
    def fibfill(fib, name, isdir, size=1234, blocks=3, prot=0,
                days=11111, mins=222, ticks=3333, comment=b'cmt'):
        mem.w32(fib+4, (1 if isdir else -1) & 0xffffffff)
        mem.w_block(fib+8, name+b'\x00')
        mem.w32(fib+116,prot); mem.w32(fib+124,size); mem.w32(fib+128,blocks)
        mem.w32(fib+132,days); mem.w32(fib+136,mins); mem.w32(fib+140,ticks)
        mem.w_block(fib+144, comment+b'\x00')
    EXI=[0]
    def tr_examine(op,pc):
        fib=cpu.r_reg(Register.D2); LOG.append(('examine',cpu.r_reg(Register.D1)))
        if EXAM_OK:
            fibfill(fib,b'RAM',FIB_ISDIR)
        r=0xffffffff if EXAM_OK else 0
        cpu.w_reg(Register.D0, r); setz(cpu, not EXAM_OK)
    def tr_exnext(op,pc):
        fib=cpu.r_reg(Register.D2); LOG.append(('exnext',cpu.r_reg(Register.D1)))
        if EXI[0] < len(EXNEXT):
            nm,isdir=EXNEXT[EXI[0]]; EXI[0]+=1
            fibfill(fib,nm,isdir,size=10+EXI[0],blocks=EXI[0],prot=EXI[0],
                    comment=b'c%d'%EXI[0])
            cpu.w_reg(Register.D0,0xffffffff); setz(cpu, False)
        else:
            cpu.w_reg(Register.D0,0); setz(cpu, True)

    # ---------------- rexxsyslib -----------------------------------
    def tr_rxs126(op,pc):     # CreateArgstring(a0=str,d0=len) -> a0/d0
        s=cpu.r_reg(Register.A0); ln=cpu.r_reg(Register.D0)
        at=mkarg(bytes(mem.r_block(s,ln)) if s else b'') if ALLOC_OK else 0
        LOG.append(('argstr',ln))
        cpu.w_reg(Register.A0,at); cpu.w_reg(Register.D0,at); setz(cpu, at==0)
    def tr_rxs132(op,pc):
        LOG.append(('delarg',cpu.r_reg(Register.A0)))
    def tr_rxs174(op,pc):     # append name node: a0=list,a1=cstr,d0=size
        hd=cpu.r_reg(Register.A0); nm=cstr(cpu.r_reg(Register.A1))
        sz=cpu.r_reg(Register.D0)
        if not RXS174_OK:
            LOG.append(('rxs174',hd,nm,0))
            cpu.w_reg(Register.D0,0); setz(cpu,True); return
        nd=POOLBASE[0]; POOLBASE[0]+=64
        mem.w32(nd,0); mem.w32(nd+10,mkarg(nm)); mem.w32(nd+20,sz)
        p=hd
        while True:
            nx=mem.r32(p)
            if nx==0 or nx==hd: break
            p=nx
        mem.w32(p,nd)
        LOG.append(('rxs174',hd,nm,nd))
        cpu.w_reg(Register.A0,nd); cpu.w_reg(Register.D0,nd); setz(cpu,False)
    def tr_rxs180(op,pc):     # find node: a0=&list,a1=name,d0=type
        a0=cpu.r_reg(Register.A0); nm=cstr(cpu.r_reg(Register.A1))
        ty=cpu.r_reg(Register.D0)&0xff
        n=mem.r32(a0); r=0
        while n:
            if cstr(mem.r32(n+10))==nm and mem.r8(n+8)==ty: r=n; break
            n=mem.r32(n)
        LOG.append(('rxs180',a0,nm,ty,r))
        cpu.w_reg(Register.D0,r); cpu.w_reg(Register.A0,r); setz(cpu, r==0)
    def tr_rxs186(op,pc):     # free stub chain -> a0=head
        hd=cpu.r_reg(Register.A0); p=mem.r32(hd); n=0
        while p and p!=hd and n<64:
            nxt=mem.r32(p); LOG.append(('rxs192f',p)); p=nxt; n+=1
        LOG.append(('rxs186',hd,n)); cpu.w_reg(Register.A0,hd)
    def tr_rxs192(op,pc):
        LOG.append(('rxs192',cpu.r_reg(Register.A0)))
    def tr_rxs198(op,pc):     # create port node: a0=&list,a1=name
        # caller runs `sne d3`: TRUE iff d0 nonzero, so success returns
        # the new node pointer (NZ) and failure returns 0 (Z).
        a0=cpu.r_reg(Register.A0); nm=cstr(cpu.r_reg(Register.A1))
        if not RXS198_OK:
            LOG.append(('rxs198',a0,nm,0))
            cpu.w_reg(Register.D0,0); setz(cpu,True); return
        nd=POOLBASE[0]; POOLBASE[0]+=96
        mem.w32(nd+0, mem.r32(a0))     # succ = old head
        mem.w32(a0, nd)                # head = node
        mem.w8(nd+8,2)                 # type
        mem.w32(nd+10, mkarg(nm))      # name
        # embedded (1.x) MsgPort at +32: SigBit@+47, MsgList@+52
        mem.w8(nd+47,7)                # sigbit 7
        head=nd+52
        if PORTQUEUE:
            mem.w32(head, PORTQUEUE[0])
            for i,msg in enumerate(PORTQUEUE):
                mem.w32(msg, PORTQUEUE[i+1] if i+1<len(PORTQUEUE) else 0)
        else:
            mem.w32(head,0)
        # pending-packet MinList at +66: head=+70(&tail), tail=0, tailpred=+66
        mem.w32(nd+66,nd+70); mem.w32(nd+70,0); mem.w32(nd+74,nd+66)
        LOG.append(('rxs198',a0,nm,nd))
        cpu.w_reg(Register.A0,nd); cpu.w_reg(Register.D0,nd); setz(cpu,False)
    def tr_rxs204(op,pc):
        LOG.append(('rxs204',cpu.r_reg(Register.A0)))
    def tr_rxs210(op,pc):     # flatten chain names -> argstring
        hd=cpu.r_reg(Register.A0); sep=cpu.r_reg(Register.D0)&0xff
        fl=cpu.r_reg(Register.D1)&0xffff
        if fl: LOG.append(('disable',))
        else:  LOG.append(('forbid',))
        out=b''; p=mem.r32(hd); n=0
        while p and p!=hd and n<64:
            s=cstr(mem.r32(p+10))
            out+=(bytes([sep]) if out else b'')+s
            p=mem.r32(p); n+=1
        if fl: LOG.append(('enable',))
        else:  LOG.append(('permit',))
        at=mkarg(out) if ALLOC_OK else 0
        LOG.append(('rxs210',hd,sep,out))
        cpu.w_reg(Register.D0,at); cpu.w_reg(Register.A0,at); setz(cpu, at==0)
    def tr_rxs222(op,pc):     # init stub list
        p=cpu.r_reg(Register.A0)
        mem.w32(p,p); mem.w32(p+4,4); mem.w32(p+8,p)
        LOG.append(('rxs222',p))
    def tr_rxs288(op,pc):
        s=cstr(cpu.r_reg(Register.A0)); cpu.w_reg(Register.D0,len(s))
    def tr_rxs294(op,pc):     # toupper char
        d=cpu.r_reg(Register.D0)&0xff
        if 97<=d<=122: d-=32
        cpu.w_reg(Register.D0,d)
    def tr_rxs306(op,pc):     # fmt decimal into a0, width d1; a0 advances
        a=cpu.r_reg(Register.A0); v=cpu.r_reg(Register.D0)
        w=cpu.r_reg(Register.D1)
        s=('%d'%(v & 0xffffffff)).encode().rjust(w)
        mem.w_block(a,s); cpu.w_reg(Register.A0,a+len(s))
        cpu.w_reg(Register.D0,len(s))
    def tr_rxs312(op,pc):     # value -> argstring
        v=cpu.r_reg(Register.D0)
        at=mkarg(('%d'%v).encode())
        LOG.append(('valstr',v))
        cpu.w_reg(Register.A0,at); cpu.w_reg(Register.D0,at); setz(cpu, at==0)
    def tr_rxs474(op,pc):     # argstring hdr -> (d0 status, d1 value)
        a=cpu.r_reg(Register.A0)
        ln=mem.r16(a+4)&0xffff if a else 0
        s=bytes(mem.r_block(a+8,ln)) if a else b''
        if s in VALCONV:
            st,v=VALCONV[s]; LOG.append(('rxs474',s,st,v))
            cpu.w_reg(Register.D0,st); cpu.w_reg(Register.D1,v&0xffffffff)
            setz(cpu, st==0); return
        try:
            t=s.decode().strip()
            if t.startswith('$'): v=int(t[1:],16)
            elif t.startswith('0x'): v=int(t,16)
            else: v=int(t,10)
            st=0
        except Exception:
            v=0; st=1
        LOG.append(('rxs474',s,st,v))
        cpu.w_reg(Register.D0,st); cpu.w_reg(Register.D1,v&0xffffffff)
        setz(cpu, st==0)

    # exec vectors
    stub(SYSB-132,tr_forbid);  stub(SYSB-138,tr_permit)
    stub(SYSB-198,tr_allocmem); stub(SYSB-210,tr_freemem)
    stub(SYSB-246,tr_addtail);  stub(SYSB-252,tr_remove)
    stub(SYSB-276,tr_findname); stub(SYSB-318,tr_wait)
    stub(SYSB-366,tr_putmsg);   stub(SYSB-372,tr_getmsg)
    stub(SYSB-378,tr_replymsg); stub(SYSB-390,tr_findport)
    stub(SYSB-414,tr_closelib); stub(SYSB-552,tr_openlib)
    # dos vectors
    stub(DOSB-72,tr_dos72);   stub(DOSB-78,tr_dos78)
    stub(DOSB-84,tr_lock);    stub(DOSB-90,tr_unlock)
    stub(DOSB-102,tr_examine);stub(DOSB-108,tr_exnext)
    stub(DOSB-120,tr_dos120); stub(DOSB-198,tr_dos198)
    # rexxsyslib vectors
    stub(RXSB-126,tr_rxs126); stub(RXSB-132,tr_rxs132)
    stub(RXSB-174,tr_rxs174); stub(RXSB-180,tr_rxs180)
    stub(RXSB-186,tr_rxs186); stub(RXSB-192,tr_rxs192)
    stub(RXSB-198,tr_rxs198); stub(RXSB-204,tr_rxs204)
    stub(RXSB-210,tr_rxs210); stub(RXSB-222,tr_rxs222)
    stub(RXSB-288,tr_rxs288); stub(RXSB-294,tr_rxs294)
    stub(RXSB-306,tr_rxs306); stub(RXSB-312,tr_rxs312)
    stub(RXSB-474,tr_rxs474)

    # rexxsyslib data fields used by the library
    mem.w32(RXSB+36, SYSB)                 # rl_SysBase (a4@(36) -> d4)
    mem.w32(RXSB+40, DOSB)                 # rl_DOSBase (a4@(40))
    # rl_FALSE/rl_TRUE/rl_NULL are stored as header addrs: callers
    # addqw #8 to reach the string data.
    mem.w32(RXSB+64, mkarg(b'')-8)         # rl_NULL
    mem.w32(RXSB+68, mkarg(b'0')-8)        # rl_FALSE
    mem.w32(RXSB+72, mkarg(b'1')-8)        # rl_TRUE

    SP=0x7ff000
    def call(pc,**regs):
        mem.w32(SP-4,ENDTRAP); cpu.w_sp(SP-4); cpu.w_pc(pc)
        for k,v in regs.items(): cpu.w32_reg(getattr(Register,k),v&0xffffffff)
        try: m.execute(60_000_000)
        except Done: pass
        return cpu.r_reg(Register.D0)
    return dict(mem=mem,cpu=cpu,call=call,LOG=LOG,CODE=CODE,LIB=LIB,
                Done=Done,m=m,POOLBASE=POOLBASE,SYSB=SYSB,RXSB=RXSB,
                DOSB=DOSB,ENDTRAP=ENDTRAP,mkarg=mkarg,rdarg=rdarg,cstr=cstr)

def makelib(E, code0):
    """replicate InitResident: word-offset function table flavour."""
    mem=E['mem']
    blk = mem.r_block(code0, 64)
    rt  = blk.index(b'\x4a\xfc')
    it  = mem.r32(code0+rt+22)
    dsz = mem.r32(it); ftab=mem.r32(it+4); dtab=mem.r32(it+8); initf=mem.r32(it+12)
    vecs=[]
    if mem.r16(ftab)==0xffff:
        i=ftab+2
        while mem.r16(i)!=0xffff:
            vecs.append(ftab+mem.r16(i)); i+=2
    else:
        i=0
        while mem.r32(ftab+i) != 0xffffffff:
            vecs.append(mem.r32(ftab+i)); i+=4
    LIB=E['LIB']; neg=len(vecs)*6
    for i,fn in enumerate(vecs):
        at = LIB-6-i*6; mem.w16(at,0x4ef9); mem.w32(at+2,fn)
    o=dtab
    while True:
        cmd=mem.r8(o); off=mem.r8(o+1); o+=2
        if cmd==0: break
        if   cmd==0xa0: mem.w8(LIB+off,mem.r8(o)); o+=2
        elif cmd==0x90: mem.w16(LIB+off,mem.r16(o)); o+=2
        elif cmd==0x80: mem.w32(LIB+off,mem.r32(o)); o+=4
        else: raise Exception('bad datatab %x'%cmd)
    mem.w16(LIB+16,neg); mem.w16(LIB+18,34+dsz)
    r=E['call'](initf, D0=LIB, A0=0x5a0000, A6=E['SYSB'])
    return LIB if r else 0, vecs

def vec(E, i): return E['LIB'] - 6 - i*6

def msg(E, name, args=()):
    """build a request block; args are raw bytes for argstrings.

    Layout (as decoded from the dispatcher at 0xde-0x184):
      a5 = MSG: +20 -> task block T, +31 = argcount (excl. name),
                +40 = name argstring, +44.. = arg argstrings.
      T:  +136 = result buffer (raw results are written here),
          +235 = caller signal bit (WAITPKT),
          +316 = internal port-node list head (type 2)."""
    mem=E['mem']; mkarg=E['mkarg']
    MSG=0x68000; T=0x6a000; BUF=0x6c000
    mem.w_block(MSG,b'\x00'*0x200)
    mem.w32(MSG+20,T)
    mem.w32(T+136,BUF)                      # a3 = *T+136 -> result buf
    mem.w32(BUF,0)
    mem.w8(MSG+31,len(args))                # argcount (excl name)
    mem.w32(MSG+40,mkarg(name if isinstance(name,bytes) else name.encode()))
    for i,a in enumerate(args):
        mem.w32(MSG+44+4*i, a if isinstance(a,int) else mkarg(a))
    mem.w32(T+316,0)                        # port list head
    mem.w8(T+235,5)                         # caller signal bit
    return MSG

def tok(E, v):
    """a 4-byte token argstring carrying pointer value v"""
    return E['mkarg'](struct.pack('>L', v & 0xffffffff))

def res(E):
    """read the returned argstring content"""
    a0=E['cpu'].r_reg(Register.A0)
    return E['rdarg'](a0) if a0 else None

def addport(E, MSG, name, sigbit=7, queue=()):
    """write a fake rxs port-node (matching tr_rxs198's layout) and
    link it into the port list at T+316 (T = mem[MSG+20]).
    queue = msg ptrs for the +52 message list inside the +32 port."""
    mem=E['mem']; mkarg=E['mkarg']
    T=mem.r32(MSG+20)
    nd=E['POOLBASE'][0]; E['POOLBASE'][0]+=96
    mem.w32(nd+0, mem.r32(T+316)); mem.w32(T+316, nd)
    mem.w8(nd+8,2); mem.w32(nd+10, mkarg(name.encode()))
    mem.w8(nd+47,sigbit)
    if queue:
        mem.w32(nd+52, queue[0])
        for i,mm in enumerate(queue):
            mem.w32(mm, queue[i+1] if i+1<len(queue) else 0)
    else:
        mem.w32(nd+52,0)
    mem.w32(nd+66,nd+70); mem.w32(nd+70,0); mem.w32(nd+74,nd+66)
    return nd

def mkpkt(E, at, action=0x01000002, args=()):
    """fake packet at `at`: +28 = action long (hi byte = class,
    byte+29 bit1 = REPLY wants-resultstring, low byte = arg count),
    +32 = Result1, +36 = Result2, +40.. = argstring ptrs"""
    mem=E['mem']
    mem.w32(at+28,action)
    for i,a in enumerate(args): mem.w32(at+40+4*i,a)
    return at

def dump(E, tag):
    a0=E['cpu'].r_reg(Register.A0); d0=E['cpu'].r_reg(Register.D0)
    # error returns (d0!=0) leave a0 = 0 or garbage; only decode on success
    r = res(E) if d0==0 and a0 else None
    print('  %-34s -> d0=%d a0=%s res=%r' % (tag, d0, ('%x'%a0) if a0 else '0', r))
    return d0, r

def run(which, relbase=0):
    E=load(which,relbase); mem=E['mem']; LOG=E['LOG']; code0=E['CODE'][0]
    lib,vecs=makelib(E, code0)
    print('lib=%x vecs=%d' % (lib, len(vecs)))
    print('hdr: type=%d flags=%02x ver=%d rev=%d neg=%d pos=%d' % (
        mem.r8(lib+8),mem.r8(lib+14),mem.r16(lib+20),mem.r16(lib+22),
        mem.r16(lib+16),mem.r16(lib+18)))
    print('name=%r' % mem.r_block(mem.r32(lib+10),32).split(b'\x00')[0])
    print('id=%r' % mem.r_block(mem.r32(lib+24),64).split(b'\x00')[0])
    print('data: sysb=%x rxs=%x seg=%x' % (
        mem.r32(lib+34),mem.r32(lib+38),mem.r32(lib+42)))
    LIB=E['LIB']; dsp=vec(E,4)

    r=E['call'](vec(E,0), A6=LIB); print('libopen -> %x opencnt=%d'%(r,mem.r16(LIB+32)))
    print('nullvec -> %x' % E['call'](vec(E,3), A6=LIB))

    def d(nm,args=()):
        m=msg(E,nm,args)
        E['call'](dsp, A0=m, A6=LIB)
        return dump(E, nm.decode()), m

    # --- dispatch errors -------------------------------------------
    d(b'Bogus');                    # name not found -> 1
    d(b'NEXT');                     # below min    -> 17
    d(b'NULL',[b'x']);              # above max    -> 17
    d(b'FORBID',[b'x']);            # above max    -> 17
    d(b'DELAY',[b'xyz']);           # conv fail    -> 18
    d(b'DELAY',[b'-1']);            # neg value    -> 18
    d(b'ALLOCMEM',[b'0']);          # zero size    -> 18
    d(b'ALLOCMEM');                 # below min    -> 17
    d(b'SHOWLIST',[b'ports',b'x',b'y',b'z']);   # arg3 != 'A' -> 18
    d(b'LONGLONGNAME');             # len>9        -> 1
    d(b'AB',[b'x']);                # len<4        -> 1

    # --- scalar/dos functions --------------------------------------
    d(b'NULL');                     # raw 4-byte zero token
    d(b'FORBID'); d(b'PERMIT');     # numeric TDNestCnt
    d(b'BADDR',[tok(E,0x12345)])    # bcpl*4 -> 0x48d14
    d(b'BADDR',[b'abc'])            # len!=4 -> 18
    d(b'NEXT',[tok(E,0x64000)])     # *(0x64000)   -> raw
    d(b'NEXT',[tok(E,0x64000),b'4'])# *(0x64004)
    d(b'NEXT',[tok(E,0x64001)])     # odd -> 18
    d(b'OFFSET',[tok(E,0x64000),b'16'])  # base+16 (not deref)
    d(b'OFFSET',[tok(E,0x64000),b'bad']) # conv fail -> 18
    d(b'DELAY',[b'5']); d(b'DELAY',[b'0'])
    d(b'DELETE',[b'work:x'])
    d(b'RENAME',[b'a',b'b'])
    d(b'MAKEDIR',[b'newdir'])
    d(b'FREEMEM',[tok(E,0x66000),b'256'])
    d(b'FREEMEM',[tok(E,0x66000),b'0'])   # size 0 -> 18
    d(b'FREEMEM',[tok(E,0),b'256'])       # ptr 0  -> 18
    d(b'ALLOCMEM',[b'100'])
    d(b'ALLOCMEM',[b'100',tok(E,0x10003)])
    d(b'ALLOCMEM',[b'100',b'zz'])         # flags token len!=4 -> 18
    d(b'STATEF',[b'ram:x'])
    d(b'SHOWDIR',[b'ram:'])
    d(b'SHOWDIR',[b'ram:',b'D'])
    d(b'SHOWDIR',[b'ram:',b'F'])
    d(b'SHOWDIR',[b'ram:',b'X'])          # bad mode -> 18

    # --- packet functions ------------------------------------------
    mkpkt(E,0x64040, action=0x01000002,
          args=[E['mkarg'](b'arg0str'),E['mkarg'](b'arg1str')])
    mem.w32(0x64040,0x64040); mem.w32(0x64044,0x64040)  # self-linked node
    d(b'TYPEPKT',[tok(E,0x64040)])       # raw action long
    d(b'TYPEPKT',[tok(E,0x64040),b'A'])  # numeric low byte
    d(b'TYPEPKT',[tok(E,0x64040),b'C'])  # bool class==1
    d(b'TYPEPKT',[tok(E,0x64040),b'F'])  # bool class==2
    d(b'TYPEPKT',[tok(E,0x64040),b'X'])  # bad sel -> 18
    d(b'TYPEPKT',[b'abc'])               # bad token -> 18
    d(b'GETARG',[tok(E,0x64040),b'0'])   # pkt+40 -> 'arg0str'
    d(b'GETARG',[tok(E,0x64040),b'1'])   # pkt+44 -> 'arg1str'
    d(b'GETARG',[tok(E,0x64040),b'2'])   # pkt+48 = 0 -> ''
    d(b'GETARG',[tok(E,0x64040),b'9'])   # out of range -> ''
    mkpkt(E,0x64080, action=0x02000001,
          args=[E['mkarg'](b'pkt2arg')])
    d(b'GETARG',[tok(E,0x64080),b'0'])   # class2 pkt arg[0]
    mkpkt(E,0x640c0, action=0x03000001)
    d(b'GETARG',[tok(E,0x640c0),b'1'])   # bad class -> 18
    mkpkt(E,0x64180, action=0x01000202)   # +29 bit1 = wants resultstr
    mem.w32(0x64180,0x64180); mem.w32(0x64184,0x64180)
    d(b'REPLY',[tok(E,0x64040),b'7'])    # rc!=0 -> no resultstr
    d(b'REPLY',[tok(E,0x64180),b'0',b'rs'])  # rc==0,flags bit1 -> resultstr
    d(b'REPLY',[tok(E,0x64180),b'0'])    # rc==0 no arg2
    d(b'FORWARD',[tok(E,0x64040),b'portname'])

    # --- port-node functions ----------------------------------------
    m=msg(E,b'GETPKT',[b'portname']); addport(E,m,'portname')
    E['call'](dsp,A0=m,A6=LIB); dump(E,'GETPKT empty-q')
    p1=mkpkt(E,0x64100); p2=mkpkt(E,0x64140)
    m=msg(E,b'GETPKT',[b'portname']); addport(E,m,'portname',queue=[p1])
    E['call'](dsp,A0=m,A6=LIB); dump(E,'GETPKT 1 pkt')
    m=msg(E,b'WAITPKT',[b'portname']); addport(E,m,'portname',queue=[p1])
    E['call'](dsp,A0=m,A6=LIB); dump(E,'WAITPKT 1 queued')
    m=msg(E,b'WAITPKT',[b'portname']); addport(E,m,'portname',queue=[p1,p2])
    E['call'](dsp,A0=m,A6=LIB); dump(E,'WAITPKT 2 queued')
    m=msg(E,b'WAITPKT',[b'nope']); addport(E,m,'portname')
    E['call'](dsp,A0=m,A6=LIB); dump(E,'WAITPKT unknown')
    m=msg(E,b'GETPKT',[b'nope']); addport(E,m,'portname')
    E['call'](dsp,A0=m,A6=LIB); dump(E,'GETPKT unknown')
    m=msg(E,b'CLOSEPORT',[b'portname']); addport(E,m,'portname')
    E['call'](dsp,A0=m,A6=LIB); dump(E,'CLOSEPORT found')
    d(b'CLOSEPORT',[b'nothere'])          # find fails -> FALSE
    d(b'OPENPORT',[b'newport'])

    # --- SHOWLIST ---------------------------------------------------
    def xnode(nm):
        at=E['POOLBASE'][0]; E['POOLBASE'][0]+=64
        mem.w32(at,0); mem.w32(at+10,E['mkarg'](nm)); return at
    n1=xnode(b'firstport'); mem.w32(E['SYSB']+392, n1)
    n2=xnode(b'runner');    mem.w32(E['SYSB']+406, n2)
    n3=xnode(b'thelib');    mem.w32(E['SYSB']+378, n3)
    n4=xnode(b'memlist');   mem.w32(E['SYSB']+322, n4)
    n5=xnode(b'res');       mem.w32(E['SYSB']+336, n5)
    n6=xnode(b'dev');       mem.w32(E['SYSB']+350, n6)
    n7=xnode(b'intr');      mem.w32(E['SYSB']+364, n7)
    n8=xnode(b'sema');      mem.w32(E['SYSB']+532, n8)
    n9=xnode(b'waiter');    mem.w32(E['SYSB']+420, n9)
    # dos device list for SHOWLIST 'A'/'H'/'V' devscan
    DOSB=E['DOSB']; root=0x64200; info=0x64300
    mem.w32(DOSB+34,root); mem.w32(root+24,info>>2)
    def devn(ty,nm,nxt=0):
        at=E['POOLBASE'][0]; E['POOLBASE'][0]+=64
        bs=E['POOLBASE'][0]; E['POOLBASE'][0]+=64
        mem.w_block(bs,bytes([len(nm)])+nm+b'\x00')
        mem.w32(at+0,nxt); mem.w32(at+4,ty); mem.w32(at+40,bs>>2)
        return at
    d1=devn(2,b'dh0'); d2=devn(1,b'sys'); d3n=devn(0,b'df0')
    mem.w32(d3n+0,d2>>2); mem.w32(d2+0,d1>>2)
    mem.w32(info+4,d3n>>2)   # di_DevList = chain of BPTRs
    for args in [[b'PORTS'],[b'TASKS'],[b'WAITING'],[b'DEVICES'],
                 [b'L'],[b'S'],[b'R'],[b'M'],[b'A'],[b'H'],[b'V'],[b'I'],
                 [b'PORTS',b'firstport'],[b'PORTS',b'noport'],
                 [b'PORTS',b'firstport',b' ',b'A'],
                 [b'PORTS',b'firstport',b','],
                 [b'@ABCD'],[b'X'],[b'ports']]:
        d(b'SHOWLIST',args)

    # --- lifecycle ---------------------------------------------------
    r=E['call'](vec(E,1), A6=LIB); print('libclose -> %x' % r)
    r=E['call'](vec(E,2), A6=LIB); print('expunge -> %x' % r)
    for e in LOG: print(e)

def main():
    run(sys.argv[1], int(sys.argv[2],0) if len(sys.argv)>2 else 0)

if __name__ == '__main__':
    main()
