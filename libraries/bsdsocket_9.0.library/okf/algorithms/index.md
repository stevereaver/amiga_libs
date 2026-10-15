# Algorithms

Proxy pattern: EngineEnter (semaphore obtain via engine -564) ->
pack msg -> WireSend(0x42,len) -> WireRead(reply) -> EngineLeave
(engine -570).  Errors via SaveErrno(-1)+return -1.
