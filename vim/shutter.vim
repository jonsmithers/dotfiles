" TODO
" What about when a quoted string spans across multiple lines in prose?
"
" WHAT ABOUT THIS:
" ((   |)
" and inserting ')'. Currently you have to press ')' twice to actually
" complete all pairs. Is it worth detecting if there's other missing pairs? We
" would search backwards and then forwards. If the backward search works but
" the forward search doesn't, then we insert a paren instead of skipping

" COOL FEATURES
" * Do not auto-close for a pre-existing RHS

" GUIDING RPINCIPLES
" Should not require any change in muscle memory

" contexts you can enable in
" 1. entire filetype
" 2. region within filetype (i.e. lit-html, jsx, html script tag, html css tag)

fun! shutter#Init()
endfun

let s:config = {}
let s:config.shutters = [
      \ { 'trigger': '>', 'close': '....', },
      \ { 'trigger': '(', 'close': ')', },
      \ { 'trigger': '[', 'close': ']', },
      \ { 'trigger': '{', 'close': '}', },
      \ ]
let s:config.symmetric_spacing = [
      \ { 'patternAtOffset': '()' },
      \ { 'patternAtOffset': '{}' },
      \ ]
let s:config.format_on_newline = [
      \ { 'patternAtOffset': '><\/[a-zA-Z\-]\+>', 'filetypes': [ 'html', 'xml'], 'regions': { 'javascript': ['litHtmlRegion', 'jsxRegion'] } },
      \ { 'patternAtOffset': '()' },
      \ { 'patternAtOffset': '[]' },
      \ { 'patternAtOffset': '{}' },
      \ ]
let s:config.shutters = {
      \}

function <SID>MaybeCloseTag()


  " syntax/filetype check
  let l:syntax = map(synstack(line('.'), col('.')), "synIDattr(v:val, 'name')")
  if (index(['javascript', 'typescript', 'javascript.tsx', 'typescript.tsx', 'html', 'xml'], &filetype) == -1)
    return '>'
  endif
  if (index(['javascript', 'typescript', 'javascript.tsx', 'typescript.tsx'], &filetype) != -1)
    let l:doNothing = 1
    for l:region in ['jsxRegion', 'tsxRegion', 'litHtmlRegion']
      echom 'testing ' . l:region
      if index(l:syntax, l:region) != -1
        let l:doNothing = 0
        break
      endif
    endfor
    if (l:doNothing)
      return '>'
    endif
  endif

  let l:tagname = GetTagName()
  if (l:tagname ==# '')
    return '>'
  endif
  return '></' . l:tagname . '>' . repeat("\<Left>", 3+len(l:tagname))
endfunction

function GetTagName()
  let l:line = getline('.')
  let l:line = strpart(l:line, 0, col('.')-1) " remove part after cursor
  let l:line = l:line . '>'
  let l:matchlist = matchlist(l:line, '<\([a-zA-Z\-]\+\)[^<>]*>$')
  if (len(l:matchlist) ==# 0)
    " TODO: search previous lines using searchpair()
    return ''
  endif
  let l:tagname = l:matchlist[1]
  return l:tagname
endfunction

inoremap <expr> > <SID>MaybeCloseTag()
inoremap <expr> <cr> MaybeSplitTag()
" inoremap <expr> " match(CharUnderCursor(), '\w') != -1 ? '"' : '""'."\<Left>"
inoremap <expr> " <SID>StartOrCloseSymmetricPair('"')
inoremap <expr> ' <SID>StartOrCloseSymmetricPair("'")
inoremap ( <c-r>=StartPair('(', ')')<cr>
inoremap ) <c-r>=ClosePair2('(', ')')<cr>
inoremap <space> <c-r>=StretchPair()<cr>
" inoremap <expr> <space> <SID>StretchPair()
inoremap { <c-r>=StartPair('{', '}')<cr>
inoremap [ <c-r>=StartPair('[', ']')<cr>
inoremap <expr> ] <SID>ClosePair('[', ']')
inoremap <expr> } <SID>ClosePair('{', '}')
inoremap <expr> <backspace> <SID>Backspace()
" imap <expr> <Del> <SID>Delete() " doesn't work with c-d?
"
fun! StretchPair()
  let l:textAtOffset = getline('.')[col('.')-1-1:]
  for l:splitter in s:config.symmetric_spacing
    if (exists('l:splitter.patternAtOffset') && -1 !=# match(l:textAtOffset, l:splitter.patternAtOffset))
      let l:newlinecontent = getline('.')[0:col('.')-2] . ' ' . getline('.')[col('.')-1:-1]
      call setline('.', l:newlinecontent)
      return ' '
    endif
  endfor
  return ' '
endfun

" 'sdf |     SHOULD INSERT SINGLE QUOTE
fun! <SID>StartOrCloseSymmetricPair(BHS)
  let l:char = CharUnderCursor()
  if (l:char ==# a:BHS)
    return "\<Right>"
  end
  " do nothing if there's an odd number of BHS characters in this line
  if (((len(split(getline('.'), a:BHS))-1) % 2) == 1)
    return a:BHS
  endif
  " do nothing if we're touching letters on the LHS (as in "Don't")
  if (match(CharBeforeCursor(), '\w') != -1)
    return a:BHS
  endif
  " do nothing for vimscript comments
  if (a:BHS ==# '"' && &filetype ==# 'vim' )
    " -1 != match(getline('.')[col('.')], '^\s*$')
    echom 'vimscript comment'
    return '"'
  endif
  return a:BHS . a:BHS . "\<Left>"
endfun

fun! StartPair(LHS, RHS)
  let l:char = CharUnderCursor()
  let l:nextchar = CharAfterCursor()
  echom 'nextchar ' . l:nextchar

  if (match(l:char, "^[0-9a-zA-Z\"']$") == 0)
    echom 'match blacklist character'
    return a:LHS
  endif
  " " do nothing if there's junk immediately after the cursor
  " if (index(['', a:RHS, a:LHS, ' '], l:nextchar) == -1)
  "   " if (l:nextchar !=# '' && l:nextchar !=# a:RHS && l:nextchar !=# a:LHS && l:nextchar !=# ' ')
  "   return a:LHS
  " endif

  " do nothing if this LHS will complete an RHS that already exists To perform
  " this check, we check that we can (first) find a closing pair item, but
  " (second) we can NOT find a starting pair item
  let l:pos = getpos('.')[1:]
  let l:matchCountA = searchpair('\M' . a:LHS, '', a:RHS, 'Wmr', '', line('w$')) " moves cursor to RHS if found
  " We use '\M' so that the '[' isn't interpreted differently
  let l:posA = getpos('.')[1:]
  let l:posB = ''
  if (l:matchCountA > 0)
    let l:matchCountB = searchpair('\M' . a:LHS, '', a:RHS, 'Wmb', '', line('w0'))
    let l:posB = getpos('.')[1:]
    if (l:matchCountB == 0)
      call cursor(l:pos)
      return a:LHS
    endif
  endif
  call cursor(l:pos)

  let l:newlinecontent = ''
  if (col('.') > 1)
    let l:newlinecontent = l:newlinecontent . getline('.')[0:col('.')-2]
  endif
  let l:newlinecontent = l:newlinecontent . a:RHS
  let l:newlinecontent = l:newlinecontent . getline('.')[col('.')-1:-1]
  call setline('.', l:newlinecontent)
  echom 'posA ' . string(l:posA) . ' posB ' . string(l:posB) . ' countA ' . l:matchCountA
  return a:LHS
endfun
fun! ClosePair2(LHS, RHS)
  if (CharUnderCursor() !=# a:RHS)
    return a:RHS
  endif
  if (CharUnderCursor() ==# a:RHS)
    let l:pos = getpos('.')[1:]
    let l:matchCount = searchpair('\M' . a:LHS, '', a:RHS, 'bWm', '', line('w0'))
    call cursor(l:pos)
    echom 'match count ' . string(l:matchCount) . ' - ' . a:LHS . ', ' . a:RHS
    if (l:matchCount > 0)
      echom 'before ' . getline('.')[0:col('.')-2]
      echom 'after ' . getline('.')[col('.')-0:-1]
      " TODO does not handle col == 1
      let l:newlinecontent = getline('.')[0:col('.')-2] . getline('.')[col('.')-0:-1]
      call setline('.', l:newlinecontent)
      return a:RHS
    endif
  endif
  return a:RHS
endfun
" )|) INSERTS PAREN
" (|) MOVES RIGHT
" ((|) INSERTS PAREN????? MAYBE THIS IS TOO HARD
fun! <SID>ClosePair(LHS, RHS)
  " do nothing we're not typing over an existing RHS
  if (CharUnderCursor() !=# a:RHS)
    return a:RHS
  endif
  if (CharUnderCursor() ==# a:RHS)
    let l:pos = getpos('.')[1:]
    let l:matchCount = searchpair('\M' . a:LHS, '', a:RHS, 'bWm', '', line('w0'))
    call cursor(l:pos)
    echom 'match count ' . string(l:matchCount) . ' - ' . a:LHS . ', ' . a:RHS
    if (l:matchCount > 0)
      return "\<right>"
    endif
  endif
  return a:RHS
endfun

fun! <SID>Backspace()
  let l:line = getline('.')
  for l:pattern in ['()', '[]', '{}', '""', "''"]
    if (-1 !=# match(l:line, l:pattern, col('.')-2))
      echom 'DELETE2'
      return "\<delete>\<backspace>"
    endif
  endfor
  for l:pattern in ['(  )', '[  ]', '{  }']
    if (-1 !=# match(l:line, '\M' . l:pattern, col('.')-4))
      echom 'DELETE'
      return "\<delete>\<backspace>"
    endif
  endfor
  echom 'normal backspace'
  return "\<backspace>"
endfun
fun! <SID>Delete()
  let l:twochars = getline('.')[col('.')-1:col('.')-0]
  if (l:twochars ==# '()')
    return "\<del>\<del>"
  endif
  if (l:twochars ==# '[]')
    return "\<del>\<del>"
  endif
  if (l:twochars ==# '{}')
    return "\<del>\<del>"
  endif
  return "\<del>"
endfun

fun! CharUnderCursor()
  return getline('.')[col('.')-1]
endfun
fun! CharBeforeCursor()
  return getline('.')[col('.')-2]
endfun
fun! CharAfterCursor()
  return getline('.')[col('.')]
endfun

fun! MaybeSplitTag()
  let l:textAtOffset = getline('.')[col('.')-1-1:]
  for l:splitter in s:config.format_on_newline
    if (exists('l:splitter.patternAtOffset') && -1 !=# match(l:textAtOffset, l:splitter.patternAtOffset))
      " We do not insert a tab character because filetype's indent file is
      " responsible for correctly indenting this
      return "\<cr>\<c-o>O"
    endif
  endfor
  return "\<cr>"
endfun
