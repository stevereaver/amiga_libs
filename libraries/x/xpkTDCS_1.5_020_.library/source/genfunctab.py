#!/usr/bin/env python3
# genfunctab.py -- emit the AUTOINIT word-offset function table for
# xpkTDCS.library.  Reads `nm` output of the pass-1 (dummy) link and
# writes a gas source with the real word offsets relative to _functab.
#
# A leading -1 word selects the relative-offset table format;
# entries are word offsets from _functab, terminated by -1.
#
# Usage: python3 genfunctab.py dummy.nm > functab.s

import sys, re

# function table order: 4 system vectors, then the six xpksub LVOs
ORDER = [
    ("_LibOpen",          "-6   Open"),
    ("_LibClose",         "-12  Close"),
    ("_LibExpunge",       "-18  Expunge"),
    ("0",                 "-24  ExtFunc (null)"),
    ("_XpksPackerInfo",   "-30  XpksPackerInfo"),
    ("_XpksPackChunk",    "-36  XpksPackChunk"),
    ("_XpksPackFree",     "-42  XpksPackFree"),
    ("_XpksPackReset",    "-48  XpksPackReset"),
    ("_XpksUnpackChunk",  "-54  XpksUnpackChunk"),
    ("0",                 "-60  XpksUnpackFree (null)"),
]

syms = {}
for line in open(sys.argv[1]):
    m = re.match(r"([0-9a-fA-F]+)\s+[TtDdBbRr]\s+(\S+)", line.strip())
    if m:
        syms[m.group(2)] = int(m.group(1), 16)

base = syms["_functab"]

print("|||")
print("||| functab.s -- AUTOINIT word-offset function table")
print("||| generated from dummy.nm; offsets relative to _functab.")
print("|||")
print("\t.section .text")
print("\t.globl\t_functab")
print("_functab:")
print("\t.word\t-1")
for name, comment in ORDER:
    if name == "0":
        off = 0
    else:
        off = syms[name] - base
    print("\t.word\t0x%x\t\t|| %s" % (off, comment))
print("\t.word\t-1")
