if exists('b:current_syntax')
  finish
endif

syn clear

highlight link EntryDateLine CursorLine
syn match EntryDateLine /^\w\w\w \w\w\w \d\d\? \d\d\d\d \d\d\?:\d\d:\d\d \?\(AM\|PM\)\?$/

highlight link BulletPoint Label
syn match BulletPoint /^\s*\(\*\|-\)/
