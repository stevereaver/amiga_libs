#!/usr/bin/env python3
# genfunctab.py -- emit the AUTOINIT word-offset function table for
# xpkTDCS.library 1.2.  Reads `nm` output of the pass-1 (dummy) link
# and writes a gas source with the real word offsets relative to
# _functab.
#
# A leading -1 word selects the relative-offset table format;
# entries are word offsets from _functab, terminated by -1.
#
# The PackFree/PackReset/UnpackFree/ExtFunc vectors in the shipped
# binary all point at _start (the moveq #0,d0 / rts stub at +0).

import sys, re

# function table order: 4 system vectors, then the six xpksub LVOs
ORDER = [
    ("_LibOpen",          "-6   Open"),
    ("_LibClose",         "-12  Close"),
    ("_LibExpunge",       "-18  Expunge"),
    ("_start",            "-24  ExtFunc (null)"),
    ("_XpksPackerInfo",   "-30  XpksPackerInfo"),
    ("_XpksPackChunk",    "-36  XpksPackChunk"),
    ("_start",            "-42  XpksPackFree (null)"),
    ("_start",            "-48  XpksPackReset (null)"),
    ("_XpksUnpackChunk",  "-54  XpksUnpackChunk"),
    ("_start",            "-60  XpksUnpackFree (null)"),
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
    off = syms[name] - base
    print("\t.word\t0x%x\t\t|| %s" % (off & 0xffff, comment))
print("\t.word\t-1")
