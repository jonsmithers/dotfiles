if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

set comments=
set comments+=b:\|
set comments+=b:\>
set comments+=fb:*
set comments+=fb:-

set formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s\\+
" add mandatory space character after default formatlistpat. Otherwise, if a
" line innocusouly starts with "7:00pm", the next line will be indented
" because vim thinks you're starting a numbered list. That's not helpful.
