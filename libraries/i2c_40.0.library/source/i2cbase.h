/*
** i2c.library 40.0 -- vector map
**
** -30 AllocI2C()      -> LONG  0 ok / 5 shutdown pending
** -36 FreeI2C()       -> 0
** -42 I2CDelay(d0)    -> previous delay (d0<0 = query)
** -48 ResetBus()      -> 0
** -54 SendI2C(d0=addrw,d1=count,a1=buf) -> packed result
** -60 ReceiveI2C(d0=addrw,d1=count,a1=buf) -> packed result
** -66 I2CStatus()     -> base+130 (never written; always 0)
** -72 I2CErrStr(d0)   -> const char *
** -78 ShutdownI2C()   -> 0
** -84 RestartI2C()    -> AllocI2C result
*/
