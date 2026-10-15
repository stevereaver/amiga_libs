# Structures

- ProTracker module: songlen byte +950, 128-entry pattern table
  +952, "M.K." signature +1084 (samples header 0..949).
- Player handle: state word +12 (1=playing), engine ptr +8,
  pos byte at -12, channel-count nibble at -4.
- Control block allocated by PTMute = 0x16c bytes.
