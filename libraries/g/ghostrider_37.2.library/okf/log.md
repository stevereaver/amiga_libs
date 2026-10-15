# Work log

- Parsed hunk: single CODE hunk, 1052 bytes; entry `moveq #20,rts`
- Mapped RomTag (AUTOINIT ver 37), InitTable (dataSize 0x2a),
  absolute functab (8 vectors + double -1), InitStruct stream
- Framework: LibInit seglist->+0x22 SysBase->+0x26; Open bumps
  count; Close decrements but NEVER expunges (dead btst);
  Expunge standard Remove+FreeMem
- Decoded -30 dispatcher: always invokes table key 0, restores
  all regs (handler results discarded, arg returned)
- Decoded -36 install/remove: IND_ADDHANDLER(9)/IND_REMHANDLER(10)
  via input.device; Interrupt pri 64, is_Code->hunk+0x2ba
- Decoded -42/-48: table keys 6/7 under Disable + movec d4,vbr
  supervisor thunk + CacheClearU + Enable; -48 preserves d1
- Decoded input handler: chain walk; RAWKEY match (keycode byte
  + qualifier&~CAPSLOCK) -> INTREQ 8/0x8008 + fn0 + swallow;
  RAWMOUSE match on button bits 12-14 == mode
- Decoded port-table protocol: FindPort("GhostRider.Port"),
  array at port+0x22 of {u16 key,u32 fn}, negative key ends
- Reloc table confirms `ln_Name = 973` literal (unrelocated bug)
- Resolved all Exec LVOs against NDK exec_lib.fd
- C reconstruction: all vectors + handler in ghostrider.c;
  resident/tables/state/supervisor thunk in ghostrider_lib.s
- Fixed InitStruct byte-init format (value in high byte of data
  word); datatab now byte-identical to original
- Built clean (only expected address-4 SYSBASE warnings);
  verified functab/datatab/LVO call sites in compiled code
