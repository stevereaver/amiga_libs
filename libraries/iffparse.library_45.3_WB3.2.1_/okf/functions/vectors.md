# Vectors (45, absolute long -> h0)

Standard iffparse.library API: Open/Close/Expunge/stub then
AllocIFF..CloseClipboard through -270. Runtime: v-30 allocates
IFFHandle (44B+40B), v-36 returns error -11 w/o clipboard.device
opened via OpenDevice, FORM/8SVX probe args exercise real parser
paths (exec -240/-336/-450/-684/-690 calls).
