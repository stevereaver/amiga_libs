# Structures

- InitTable dataSize 0x4c.
- Globals pool (zeroed longs embedded after the strings in .text):
  LAB_00B2=DOSBase, LAB_00B4=IntuitionBase, LAB_00B3=GfxBase,
  LAB_00AB=IOStdReq ptr, LAB_00BB=tick word, LAB_00B5=alloc flag,
  LAB_009C+2 = 18-byte scratch string block.
- IOStdReq primed with io_Command=0x25, io_Length=1, io_Data=0,
  io_Offset=caller arg.
