# Functions

See index.md table.  The library splits roles: this .library
parses modules + maintains the play-state word (+12) and position
fields; the actual Paula mixing happens in a spawned
"ptreplay_server" task the lib communicates with.
