# Calls into dos.library internal vectors

ToshFunc0/9/10/11/12 `jsr -30/-60/-84` **on DOSBase** - BCPL-era
dos.library private entries, not documented LVOs.  -60 is the
packet dispatcher; -84/-30 are other internal routines taking
pre-loaded regs.  This lib reaches into dos internals that are
not part of the public API - version-sensitive quirk (KS1.x dos).
