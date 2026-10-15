# Vectors (41, absolute longword, LVO -6..-246)

- -6/-12/-18: Open/Close/Expunge @h0+0x136/0x148... (functab @h0+0x82)
- -24: reserved -> 0
- Numerous mid/high LVOs are thin forwarders into a second embedded
  library base ("lib2" in oracle stubs): jsr a6 calls at LVOs
  -30,-48,-54,-60,-84,-102,-114,-132,-138,-144,-150,-222.
- Under synthetic args: several entry points return
  0xfffffff6/-0xa / 0xfffffff4 / 0xfffffff3 (early error exits).
- Expunge: Remove + FreeMem(lib,0x154) + CloseLibrary x3
  (dos/intuition/graphics).
