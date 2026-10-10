# warpHW.library — public functions

- `-30 whwDesc()` : pointer to the driver descriptor.
- `-36 whwVer()`  : returns 1.
- `-42 whwFindIO()`: find the PPC window (0x40000000..0x7fff)
  in the SysBase+322 list; returns its upper bound.
- `-48 whwPoke3()`: BlizzardPPC register-write sequence.
- `-54 whwPoke4()`: write $01 to $f60038.
- `-60 whwPPC()`  : pointer to embedded PPC code.
