# Functions

| LVO  | vector | original hunk offset |
|------|--------|----------------------|
| -6   | [LibOpen](LibOpen.md)     | 0x82  |
| -12  | [LibClose](LibClose.md)   | 0x90  |
| -18  | [LibExpunge](LibExpunge.md) | 0xa4 |
| -24  | [LibNull](LibNull.md)     | 0xe6  |
| -30  | [GRDispatch](GRDispatch.md) | 0xea |
| -36  | [GRArm](GRArm.md)         | 0x1b6 |
| -42  | [GRCall6](GRCall6.md)     | 0x138 |
| -48  | [GRCall7](GRCall7.md)     | 0x164 |

Internal helpers (not exported): LibInit @0x72, launcher-table
lookup @0x100, supervisor/VBR helper @0x194, input.device setup
@0x260, teardown @0x2a4, input handler @0x2ba (is_Code target).
