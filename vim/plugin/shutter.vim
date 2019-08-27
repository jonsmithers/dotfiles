" Author:       Jon Smithers <mail@jonsmithers.link>
" Last Updated: 2019-08-26
" URL:          https://github.com/jonsmithers/dotfiles/blob/master/vim/shutter.vim
" About:        Auto-closes paired characters (parens, brackets, and tags)

" COOL FEATURES:
" * Do not auto-close for a pre-existing RHS
" * Does a better job of not skipping over RHS insertion when you actually intend to insert one
" GUIDING RPINCIPLES:
" * Should not require any change in muscle memory

" TODO: What about when a quoted string spans across multiple lines in prose?
"
" TODO: WHAT ABOUT THIS:
" ((   |)
" and inserting ')'. Currently you have to press ')' twice to actually
" complete all pairs. This breaks muscle memory. Is it worth detecting if
" there's other missing pairs? We would search backwards and then forwards. If
" the backward search works but the forward search doesn't, then we insert a
" paren instead of skipping
"
" TODO: add ability to close multi-line tag openers

let s:config = {}
let s:config.symmetric_spacing = [
      \ { 'patternAtOffset': '()' },
      \ { 'patternAtOffset': '{}' },
      \ ]
        " we exclude [] because it makes it difficult to type the markdown
        " todo item "[ ]"
let s:config.format_on_newline = [
      \ { 'patternAtOffset': '><\/[a-zA-Z\-]\+>', 'filetypes': [ 'html', 'xml'], 'regions': { 'javascript': ['litHtmlRegion', 'jsxRegion'] } },
      \ { 'patternAtOffset': '()' },
      \ { 'patternAtOffset': '[]' },
      \ { 'patternAtOffset': '{}' },
      \ ]

fun!s:Debug(msg)
  if (exists('g:shutter_debug'))
    echom a:msg
  endif
endfun

fun! <SID>MaybeCloseTag()

  " syntax/filetype check
  let l:syntax = map(synstack(line('.'), col('.')), "synIDattr(v:val, 'name')")
  if (index(['javascript', 'typescript', 'javascript.tsx', 'typescript.tsx', 'html', 'xml'], &filetype) == -1)
    return '>'
  endif
  if (index(['javascript', 'typescript', 'javascript.tsx', 'typescript.tsx'], &filetype) != -1)
    let l:doNothing = 1
    for l:region in ['jsxRegion', 'tsxRegion', 'litHtmlRegion']
      call s:Debug('testing ' . l:region)
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
endfun

fun! GetTagName()
  let l:line = getline('.')
  let l:line = strpart(l:line, 0, col('.')-1) " remove part after cursor
  let l:line = l:line . '>'
  let l:matchlist = matchlist(l:line, '<\([a-zA-Z\-]\+\)[^<>]*>$')
  if (len(l:matchlist) ==# 0)
    " TODO: search previous lines for tag name using searchpair()
    return ''
  endif
  let l:tagname = l:matchlist[1]
  return l:tagname
endfun

inoremap <silent> <expr> > <SID>MaybeCloseTag()
inoremap <silent> <expr> <cr> MaybeSplitTag()
" inoremap <silent> <expr> " match(CharUnderCursor(), '\w') != -1 ? '"' : '""'."\<Left>"
inoremap <silent> <expr> " <SID>StartOrCloseSymmetricPair('"')
inoremap <silent> <expr> ' <SID>StartOrCloseSymmetricPair("'")
inoremap <silent> ( <c-r>=StartPair('(', ')')<cr>
inoremap <silent> ) <c-r>=ClosePair2('(', ')')<cr>
inoremap <silent> <space> <c-r>=StretchPair()<cr>
" inoremap <silent> <expr> <space> <SID>StretchPair()
inoremap <silent> { <c-r>=StartPair('{', '}')<cr>
inoremap <silent> [ <c-r>=StartPair('[', ']')<cr>
inoremap <silent> <expr> ] <SID>ClosePair('[', ']')
inoremap <silent> <expr> } <SID>ClosePair('{', '}')
inoremap <silent> <expr> <backspace> <SID>Backspace()
" imap <expr> <Del> <SID>Delete() " doesn't work with c-d?
"
fun! StretchPair()
  call s:HideVimCursorSpasm()
  let l:textAtOffset = getline('.')[col('.')-1-1:]
  for l:splitter in s:config.symmetric_spacing
    if (exists('l:splitter.patternAtOffset') && -1 !=# match(l:textAtOffset, '^' . l:splitter.patternAtOffset))
      let l:newlinecontent = getline('.')[0:col('.')-2] . ' ' . getline('.')[col('.')-1:-1]
      call setline('.', l:newlinecontent)
      return ' '
    endif
  endfor
  return ' '
endfun

fun! s:HideVimCursorSpasm()
  if !has('nvim') && !has('gui_running') | redraw | end "hide cursor spasm that only occurs in vim
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
    call s:Debug('vimscript comment')
    return '"'
  endif
  return a:BHS . a:BHS . "\<Left>"
endfun

fun! StartPair(LHS, RHS)
  call s:HideVimCursorSpasm()
  let l:char = CharUnderCursor()
  let l:nextchar = CharAfterCursor()
  call s:Debug('nextchar ' . l:nextchar)

  if (match(l:char, "^[0-9a-zA-Z\"']$") == 0)
    call s:Debug('match blacklist character')
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
  call s:Debug('posA ' . string(l:posA) . ' posB ' . string(l:posB) . ' countA ' . l:matchCountA)
  return a:LHS
endfun
fun! ClosePair2(LHS, RHS)
  call s:HideVimCursorSpasm()
  if (CharUnderCursor() !=# a:RHS)
    return a:RHS
  endif
  if (CharUnderCursor() ==# a:RHS)
    let l:pos = getpos('.')[1:]
    let l:matchCount = searchpair('\M' . a:LHS, '', a:RHS, 'bWm', '', line('w0'))
    call s:Debug('match count ' . string(l:matchCount) . ' - ' . a:LHS . ', ' . a:RHS)
    if (l:matchCount > 0)
      call s:Debug('before ' . getline('.')[0:col('.')-2])
      call s:Debug('after ' . getline('.')[col('.')-0:-1])

      " EXPERIMENTAL: see if the NEXT pair start is missing a pair end, then
      " we DON'T skip insert
      let l:matchCount = searchpair('\M' . a:LHS, '', a:RHS, 'bWm', '', line('w0'))
      if (l:matchCount > 0)
        let l:matchCount = searchpair('\M' . a:LHS, '', a:RHS, 'Wm', '', line('w$'))
        if (l:matchCount == 0)
          call cursor(l:pos)
          return a:RHS
        end
      endif

      call cursor(l:pos)
      " TODO does not handle col == 1
      let l:newlinecontent = getline('.')[0:col('.')-2] . getline('.')[col('.')-0:-1]
      call setline('.', l:newlinecontent)
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
    call s:Debug('match count ' . string(l:matchCount) . ' - ' . a:LHS . ', ' . a:RHS)
    if (l:matchCount > 0)
      return "\<right>"
    endif
  endif
  return a:RHS
endfun

fun! <SID>Backspace()
  let l:line = getline('.')
  for l:pattern in ['^()', '^[]', '^{}', '^""', "^''"]
    if (-1 !=# match(l:line, l:pattern, col('.')-2))
      call s:Debug('DELETE2')
      return "\<delete>\<backspace>"
    endif
  endfor
  for l:pattern in ['^(  )', '^[  ]', '^{  }']
    if (-1 !=# match(l:line, '\M' . l:pattern, col('.')-4))
      call s:Debug('DELETE')
      return "\<delete>\<backspace>"
    endif
  endfor
  call s:Debug('normal backspace')
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
