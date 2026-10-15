/*
 * explode.library 4.6 - "Executable exploder" (1 Feb 1990)
 *
 * Reconstruction base/frame definitions.
 *
 * The original library keeps its private state in a 0x3e-byte stack
 * frame (A4) plus five longs appended to the Library node (dataSize
 * 0x36).  Offsets mirror the shipped binary exactly.
 *
 * Differences vs the 4.3 build: the decoder frame shrank from 0x44
 * to 0x3e - the saved task handle/priority moved out of the frame
 * onto the stack, so xf_outcount now sits at +58 (0x3a).
 */
#ifndef EXPLBASE_H
#define EXPLBASE_H

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/nodes.h>
#include <exec/memory.h>
#include <proto/exec.h>

/* library private fields appended after struct Library (0x22) */
struct ExplodeBase {
    struct Library  xb_lib;
    struct Library *xb_dosbase;      /* +0x22 */
    APTR            xb_seglist;      /* +0x26 */
    UWORD           xb_opencnt;      /* +0x2a - private, lib_OpenCnt is NOT used */
    ULONG           xb_stub_ctr1;    /* +0x2e - patched stub: decrunch count */
    ULONG           xb_stub_ctr2;    /* +0x32 - patched stub: bytes decrunched */
};                                   /* = 0x36 */

/*
 * The 0x3e-byte decoder frame built on the stack (A4 in original).
 * The 12 bytes at +8 serve two overlapping tables:
 *   len_base[i] = tbl[i]     for i = 0..7
 *   len_bits[i] = tbl[4 + i] for i = 0..7
 * (indexing: distance low uses tbl[cls] and tbl[8+cls], so the
 * second half doubles as the low-distance bit/base tables)
 */
struct ExplodeFrame {
    UWORD xf_litcount;     /* +0   literals left in current run        */
    UBYTE xf_bitbuf;       /* +2   bit reservoir                       */
    UBYTE xf_pending;      /* +3   match length left when ring drained */
    LONG  xf_blocks;       /* +4   block count, sign selects rounding  */
    UBYTE xf_tbl[12];      /* +8   len_base[0..7] || len_bits[0..7]    */
    UWORD xf_range[8];     /* +20  1<<bits per distance class          */
    /* +28: xf_range[4..7] get xf_range[0..3] added in - cumulative     */
    UBYTE xf_offbits[12];  /* +36  distance bit table (12 bytes)       */
    ULONG xf_pad48;        /* +48  ring pull window                    */
    APTR  xf_chain;        /* +52  hunk/pointer chain base             */
    WORD  xf_nsegs;        /* +56  chain length - 1                    */
    ULONG xf_outcount;     /* +58  bytes copied to output              */
};                               /* = 0x3e */

/*
 * Packed-stream header (read forward at blob start, data then read
 * BACKWARD from the blob end):
 *   byte 0: format in low nibble (indexes a 12-byte table, 0..8 valid)
 *   byte 1: bit reservoir seed
 *   word  : initial literal-run count
 *   long  : block count (sign bit affects range rounding)
 */

void explode_setup(struct ExplodeFrame *f, UBYTE *hdr, APTR chain);
/*
 * Record-driven copy-out: pulls tagged 4-byte records from the ring,
 * writes payloads to segment bases, applies relocation groups, then
 * frees the staging hunks.  Returns bytes emitted (xf_outcount).
 */
ULONG explode_run(struct ExplodeFrame *f, UBYTE *src, APTR chain,
                  UBYTE *ring_lo, UWORD ring_sz);
/* whole decoder entry: returns the decrunched entry point (chain+4) */
UBYTE *explode_do(struct ExplodeFrame *f, UBYTE *stream);

/* helpers exposed for the asm shim */
UBYTE *explode_chaindata(APTR chain, WORD index);   /* LAB_0055 */

#endif
