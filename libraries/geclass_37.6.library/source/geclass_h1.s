/* geclass.library 37.6 -- hunk1: BSS, 0x30 longs (0xc0 bytes).
 * All library-private state lives here; the code hunk reaches it
 * via absolute `lea _bss:l` longwords relocated against hunk1.
 *
 *   +0x00..0x0b  unused (zeroed)
 *   +0x0c        seglist (returned by expunge)
 *   +0x10        library base (cleared = init-fail flag)
 *   +0x14..0x71  unused
 *   +0x72        exec lib_Version copy
 *   +0x74..0x7f  unused
 *   +0x80        saved SP for init longjmp bailout
 *   +0x84        init failure continuation (-> 0x120)
 *   +0x88        cleanup-once latch (bit0)
 *   +0x8c        dependency init/close counter
 *   +0x90        GetFileImageClass (frameiclass subclass)
 *   +0x94        textfieldgclass (from iff.library -30)
 *   +0x98        iff.library base
 *   +0x9c/0xa0/0x9e  exec.library    cnt/base/ver
 *   +0xa4        module counter (stubs 0x194/0x196)
 *   +0xa8/0xac/0xaa  utility.library cnt/base/ver
 *   +0xb0/0xb4/0xb2  graphics.library cnt/base/ver
 *   +0xb8/0xbc/0xba  intuition.library cnt/base/ver
 */
	.bss
	.global	_bss
_bss:	.space	0xc0
