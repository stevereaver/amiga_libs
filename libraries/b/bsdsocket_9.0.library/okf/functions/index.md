# Functions (canonical bsdsocket_lib.fd order)

-30 socket  -36 bind  -42 listen  -48 accept  -54 connect
-60 sendto  -66 send  -72 recvfrom  -78 recv  -84 shutdown
-90 setsockopt  -96 getsockopt  -102 getsockname  -108 getpeername
-114 IoctlSocket  -120 CloseSocket  -126 WaitSelect
-132 SetSocketSignals  -138 getdtablesize
-144/-150/-156: return -1 stubs (gethostid/gethostname-ish)
-162 field getter  -168..-186 misc/syslog stubs
-198 Errno  -204 SetErrnoPtr  -210 Inet_NtoA  -216 inet_addr
-222..-288: inet_* helpers, Dup2Socket, ObtainSocket, ReleaseSocket
-294..-306: Is_Localhost + no-op stubs
