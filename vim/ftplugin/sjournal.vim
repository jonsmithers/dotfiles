if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

set comments=
set comments+=b:\|
set comments+=b:\>
set comments+=fb:*
set comments+=fb:-

" TODO move this into syntax/
highlight link EntryDateLine Comment
match EntryDateLine /^\w\w\w \w\w\w \d\d\? \d\d\d\d \d\d\?:\d\d:\d\d \?\(AM\|PM\)\?$/
