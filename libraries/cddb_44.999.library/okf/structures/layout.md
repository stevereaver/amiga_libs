# cddb.library 44.999 — layout

## Hunks
- h0 CODE 622 lw (0x9b8): stub+RomTag 0x00-0x1f, init 0x20, vectors
  0xc4-0x715, err strings 0x716-0x865, functab 0x868, name 0x88c,
  idstr 0x89c, runlist 0x8b0, sdiv 0x8e8, divmod 0x91a, tail 0x9aa.
- h1 DATA 26 lw (0x68): pad 0x00, InitTable 0x04-0x13
  (dsize 0x9c, ftab->h0+0x868, dtab 0, initfn->h0+0x20),
  +0x14/+0x18 zero slots (runtime lib bases land at ctx+20/+24),
  +0x1c..0x50 fourteen h0 pointers (12 err strings + runlist + stub0),
  +0x54/+0x58 zero (fn-list terminator), +0x5c=0x4c fixup delta,
  +0x60=1 fixup count, +0x64=0x5c delta.

## Library (dsize 0x9c)
- +32.w opencnt; +14 flags; +34 seglist
- +48 .. +152: ctx — 96-byte copy of h1[0..96):
  ctx+0x14? actually ctx+20 = freedb base, ctx+24 = utility base,
  ctx+0x1c..0x50 = relocated pointer table (error strings + fns),
  ctx+0x5c = fn-list cursor (init fixup -> &ctx[0x4c]),
  ctx+0x64 = runlist done flag (NOT in copied range -> starts 0).
- +152 (ctx+104) execbase — beyond the 96-byte copy.

## Init mechanics
initfn copies h1[0..95] -> lib+48 via overlap loop
(`cmpiw #0x1cd9,d0` whose operand word is `moveb (a1)+,(a6)+`,
entered mid-instruction by the `bccs` loop; first pass executes the
cmpiw, so 96 bytes copy total). Then a generic fixup loop walks
{count=h1+0x60, delta list h1+0x64}: one entry, 0x5c ->
ctx[0x5c] += ctx, turning it into a self-relative pointer to the
fn-list head ctx+0x4c = {_runlist, _stub0, 0}.

## CDInfo (input, -42/-30)
- +0,+1,+2 per track: min,sec,frame bytes, stride 4
- +400 ntracks, +404 leadout (frames), +408 discid out (-42)
## query result (freedb ctx, -30)
- a5+0 head copied to tag[0x80000001] ptr, +40 title (30) ->
  tag[0x80000002] ptr, +552 (100) -> tag[0x80000004] ptr,
  +808 (100) -> tag[0x80000003] ptr, +1324+4i track strs ->
  tag[0x80000005] list; +16/+20/+24/+36/+44 discid fields.
