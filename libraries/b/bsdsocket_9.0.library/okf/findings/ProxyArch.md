# Proxy architecture

No socket logic lives in this binary: every API call is marshaled
into a tagged message and forwarded to an engine object (the actual
TCP/IP stack).  The engine base is opened at init; calls are
bracketed by -564/-570 (semaphore enter/leave).  6 slots are stub
aliases (3x return -1, 3x return 0) - features this build does not
implement (resolver/gethostname family most likely).
