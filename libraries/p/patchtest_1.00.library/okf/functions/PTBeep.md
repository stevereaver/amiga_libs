# PTBeep (LVO -30)

The library's only public function: loads the intuition base
from the private data (a4+0x14) into a6 and calls intuition
LVO -96 (`DisplayBeep`) with a0 = NULL.  No NULL check --
calling it after a failed OpenLibrary crashes, as shipped.
