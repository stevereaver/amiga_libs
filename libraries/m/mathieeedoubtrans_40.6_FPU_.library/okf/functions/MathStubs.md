---
type: Function
title: Monadic stubs
description: The 13 push/fXXXd/pop wrappers.
---

# Monadic stubs — Atan Sin Cos Tan Sinh Cosh Tanh Exp Log
Sqrt Asin Acos Log10

All share one 20-byte shape (each followed by a 0x0000 pad):

    moveml d0-d1,-(sp)   | push the d0:d1 double
    fXXXd  sp@,fp0       | 68881 double op on the image
    fmoved fp0,sp@       | store result over it
    movel  sp@+,d0
    movel  sp@+,d1       | result in d0:d1
    rts

| LVO | name | op |
|-----|------|----|
| -30 | IEEEDPAtan  | fatand  (0a) |
| -36 | IEEEDPSin   | fsind   (0e) |
| -42 | IEEEDPCos   | fcosd   (1d) |
| -48 | IEEEDPTan   | ftand   (0f) |
| -60 | IEEEDPSinh  | fsinhd  (02) |
| -66 | IEEEDPCosh  | fcoshd  (19) |
| -72 | IEEEDPTanh  | ftanhd  (09) |
| -78 | IEEEDPExp   | fetoxd  (10) |
| -84 | IEEEDPLog   | flognd  (14) |
| -96 | IEEEDPSqrt  | fsqrtd  (04) |
| -114| IEEEDPAsin  | fasind  (0c) |
| -120| IEEEDPAcos  | facosd  (1c) |
| -126| IEEEDPLog10 | flog10d (15) |