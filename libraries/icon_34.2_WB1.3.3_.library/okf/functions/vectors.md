# Vectors (17, absolute long, LVO -6..-102)

Standard icon.library 34.x layout:
-6 Open / -12 Close / -18 Expunge / -24 reserved(0).
-30 GetDiskObject(->0xa8 buf), -36 PutDiskObject(->0x104=?),
-42 FreeDiskObject(->a0), -48 FindToolType, -54 MatchToolValue(->0x80),
-60 BumpRevision(->lib), -66..-102 further icon/diskobject helpers.
All traced deterministically under oracle stubs.
