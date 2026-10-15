/*
 * queue.library 3.2 -- hunk2 (CODE): absolute-long functab, name/id
 * strings, trailing "ad" bytes (leftover, preserved verbatim).
 * relocs: all 13 functab entries -> h0, descending order.
 */
	.text
	.globl	_functab
_functab:
	.long	_open
	.long	_close
	.long	_expunge
	.long	_qstub
	.long	_create
	.long	_delete
	.long	_enq
	.long	_rmwait
	.long	_deq
	.long	_walk
	.long	_clean
	.long	_alloc
	.long	_free
	.long	0xffffffff
	.globl	_qname
_qname:	.ascii	"queue.library"
	.byte	0
	.short	0
	.globl	_qidstr
_qidstr:
	.ascii	"queue.library 3.2"
	.byte	0
	.ascii	"ad"
