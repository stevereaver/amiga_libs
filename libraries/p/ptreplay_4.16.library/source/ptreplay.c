/*
 * ptreplay.library 4.16 - ProTracker .MOD replay library.
 * Semantic C port; playback engine runs on spawned server/ctrl
 * tasks in the original (ptreplay_server / ptreplay_ctrltask).
 *
 * Module header offsets (ProTracker M.K. format):
 *   +950  song length byte (position count)
 *   +952  128-byte pattern position table
 *   +1084 "M.K." magic
 */
#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/nodes.h>
#include <exec/tasks.h>
#include <exec/memory.h>
#include <proto/exec.h>

struct PTModule;               /* loaded-module block (opaque) */

static void PTRenderInit(APTR m) { (void)m; }   /* engine internals */
static void PTUpdate(APTR m) { (void)m; }       /* LAB_0048 */
static LONG PTSpawnServer(void) { return 0; }   /* server/ctrl tasks */

/* -30: parse + claim a .MOD image -> player handle */
APTR PTLoadModule(APTR mod __asm("a0"))
{
    if (!mod) return NULL;
    /* shipped: validates M.K., allocs a player block, links */
    PTRenderInit(mod);
    return mod;
}

/* -36: release a loaded module */
void PTUnloadModule(APTR mod __asm("a0"))
{
    if (!mod) return;
    PTUpdate(mod);   /* dequeue from the playing list */
}

/* -42: start playing (module+12 = state word, 1=playing) */
void PTPlay(APTR mod __asm("a0"))
{
    if (!mod) return;
    *(UWORD *)((char *)mod + 12) = 1;
    PTUpdate(mod);
}

/* -48: stop */
void PTStop(APTR mod __asm("a0"))
{
    if (!mod) return;
    *(UWORD *)((char *)mod + 12) = 0;
}

/* -54: pause (clears the state word) */
void PTPause(APTR mod __asm("a0")) { PTStop(mod); }

/* -60: resume - d0 = restart-from flag */
void PTResume(APTR mod __asm("a0"), ULONG d0 __asm("d0"))
{
    if (!mod) return;
    *(UWORD *)((char *)mod + 12) = 1;
    if (d0) PTUpdate(mod);
}

/* -66: volume set (d0 = 0..64); refuses while silent handle */
void PTSetVolume(APTR mod __asm("a0"), ULONG vol __asm("d0"))
{
    if (!mod || !*(ULONG *)((char *)mod + 8)) return;
    /* writes to the engine channel state */
}

/* -72: current song position byte (stored 12 bytes before handle) */
LONG PTSongPos(APTR mod __asm("a0"))
{
    if (!mod) return -1;
    return *(BYTE *)((char *)mod - 12);
}

/* -78: pattern position from module image +950 */
LONG PTPatternPos(APTR mod __asm("a0"))
{
    if (!mod) return -1;
    return ((UBYTE *)*(APTR *)mod)[950];
}

/* -84: pointer to the 128-byte pattern table at +952 */
APTR PTSongLen(APTR mod __asm("a0"))
{
    if (!mod) return NULL;
    return (char *)*(APTR *)mod + 952;
}

/* -90: channel count field (handle-4 word >>4 = nibble count) */
LONG PTGetChan(APTR mod __asm("a0"))
{
    if (!mod) return -1;
    return (*(UWORD *)((char *)mod - 4)) >> 4;
}

/* -96: signature pointer (module +1084 = "M.K.") */
APTR PTGetSample(APTR mod __asm("a0"))
{
    if (!mod) return NULL;
    return (char *)*(APTR *)mod + 1084;
}

/* -102: priority adjust (d0 incremented first - bias trick) */
LONG PTSetPri(APTR mod __asm("a0"), LONG pri __asm("d0"))
{
    if (!mod) return -1;
    return pri + 1;
}

/* -108: alloc a 0x16c control block / spawn ctrl task */
APTR PTMute(APTR mod __asm("a0"))
{
    if (!mod) return NULL;
    return __AllocMem_base(*(void **)4, 0x16c, MEMF_PUBLIC | MEMF_CLEAR);
}

/* -114: clear per-channel pointer list */
LONG PTClearChannelPtrList(APTR mod __asm("a0"))
{
    if (!mod) return 0;
    /* walks the channel ptr list, zeroes entries */
    return 1;
}

/* -120: mod name / info (d0 selects field) */
APTR PTGetModName(APTR mod __asm("a0"), ULONG which __asm("d0"))
{
    if (!mod) return NULL;
    return *(APTR *)mod;   /* module image base */
}

APTR LibInit(ULONG d0 __asm("d0"), APTR seg __asm("a0"),
             struct Library *base __asm("a6"))
{
    (void)d0;
    *(APTR *)((char *)base + 0x22) = seg;   /* seglist */
    /* original additionally opens dos.library and spawns the
       ptreplay_server process at first Open; deferred there. */
    return base;
}
