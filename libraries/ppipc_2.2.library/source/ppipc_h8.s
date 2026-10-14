/* ppipc.library 2.2 -- hunk8 DATA (0x10 bytes)
 * broker port name string. */

	.globl	_brokername

	.data
_brokername:
	.ascii	"PortBrokerPort\0"
	.byte	0				/* pad to 0x10 */
