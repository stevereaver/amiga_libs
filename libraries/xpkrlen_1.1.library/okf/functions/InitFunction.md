# InitFunction (via DATA-hunk InitTable)

Manual init (no InitStruct): fills ln_Type/ln_Name/lib_Flags/
version/revision/IdString, stores seglist at +0x22, then copies the
256-byte DATA template to base+0x3a and applies 4 pointer fixups
from the offset table at template+0x100 (fields hold
template-relative offsets that get biased to absolute addresses).
