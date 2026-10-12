#!/usr/bin/env python3
# genscript.py -- emit a copy of the stock amiga.x linker script with
# the .datachip output section moved before .data so that the chip
# data hunk lands between the code and data hunks (the original
# pointer.library layout: CODE, DATA|CHIP, DATA).

import sys

src = open(sys.argv[1]).read()

block = """  .datachip :
  {
    *(.datachip)
  }
"""
assert block in src, ".datachip block not found"
src = src.replace(block, "")
marker = "  .data :\n  {"
assert marker in src, ".data block not found"
src = src.replace(marker, block + marker, 1)
sys.stdout.write(src)
