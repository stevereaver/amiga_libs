# Findings & defects

- Extended 26B resident (extra ptr -> late body), same stub family
  as hgrexxsupport/virtualmem/multifunction.
- v-30 wires the audio path: audio.device OpenDevice, ciab.resource,
  misc.resource unit ops — real PT CIA-driven player.
- Close underflows opencnt (2 closes -> cnt 0xffff) and still runs
  Remove+FreeMem — same defect pattern as bfbplayBMOD.
- 0 invalid accesses; deterministic.
