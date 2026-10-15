# mcpsupport2.library — wildcard matcher

`-48` implements a recursive AmigaDOS wildcard matcher over
the caller's pattern string.  Tokens:

- `?`  any single character
- `#x` zero or more occurrences of token `x`
   (`#?` = the common "match anything" token)
- `(a|b|c)` alternation group
- `~p` negation — the run must NOT match `p`
- literal chars compare case-insensitively via utility
  `ToUpper` (LVO -174)

The matcher is greedy / first-match-wins and non-
backtracking across alternatives — it advances the pattern
and string cursors and returns 1 when the pattern run is
consumed with the string exhausted.  `#` is handled by
trying the following token's repetition against successive
string positions until the remainder matches.
