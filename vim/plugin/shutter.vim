" Author:       Jon Smithers <mail@jonsmithers.link>
" Last Updated: 2020-07-21
" URL:          https://github.com/jonsmithers/dotfiles/blob/master/vim/plugin/shutter.vim

" ABOUT:
" Shutter.vim auto-closes paired characters like ( [ { " '. It also
" auto-closes tags like <div> inside appropriate filetypes.
"
" Unlike many similar plugins or IDE implementations of this, shutter.vim aims
" to avoid forcing the user to rewire muscle memory.
"
" Characteristics:
" - It does not auto-close a pair if you're in a spot where you're less likely
"   to want it auto-closed.
" - It does not auto-close a pair if there exists a matching right-hand-side
"   character within the viewport.
" - It does a better job of LETTING you insert a pair-closing character even
"   when your cursor is already on top of a pair-closing character. This
"   accomplished by checking to see if there is a missing right-hand-side pair
"   character.
" - It maps <CR> without clobbering vim-endwise

" TODO: What about when a quoted string spans across multiple lines in prose?
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
      \ { 'patternAtOffset': '><\/[a-zA-Z\-]*>', 'filetypes': [ 'html', 'xml'], 'regions': { 'javascript': ['litHtmlRegion', 'jsxRegion'] } },
      \ { 'patternAtOffset': '()' },
      \ { 'patternAtOffset': '[]' },
      \ { 'patternAtOffset': '{}' },
      \ ]

fun! s:debug(msg)
  if (exists('g:shutter_debug'))
    echom 'shutter ' . line('.') . ': ' . a:msg
  endif
endfun

fun! <SID>MaybeCloseTag()

  " syntax/filetype check
  let l:syntax = map(synstack(line('.'), col('.')), "synIDattr(v:val, 'name')")
  if (index(['javascript', 'typescript', 'javascript.tsx', 'typescript.tsx', 'javascriptreact', 'typescriptreact', 'html', 'xml'], &filetype) == -1)
    return '>'
  endif
  if (index(['javascript', 'typescript', 'javascript.tsx', 'typescript.tsx', 'javascriptreact', 'typescriptreact'], &filetype) != -1)
    let l:doNothing = 1
    for l:region in ['jsxRegion', 'tsxRegion', 'litHtmlRegion', 'typescriptParenExp']
      call s:debug('testing ' . l:region)
      if index(l:syntax, l:region) != -1
        call s:debug('doing something')
        let l:doNothing = 0
        break
      endif
    endfor
    if (l:doNothing)
      return '>'
    endif
  endif

  let l:tagname = GetTagName()
  if (l:tagname ==# 'react-fragment')
    return '></>' . repeat("\<Left>", 3)
  endif
  if (l:tagname ==# '')
    return '>'
  endif
  return '></' . l:tagname . '>' . repeat("\<Left>", 3+len(l:tagname))
endfun

fun! GetTagName()
  let l:line = getline('.')
  let l:line = strpart(l:line, 0, col('.')-1) " remove part after cursor
  let l:line = l:line . '>'
  let l:matchlist = matchlist(l:line, '<\([a-zA-Z\-]\+\)[^<>/]*>$')
  if (len(l:matchlist) ==# 0)
    call s:debug(l:line)
    if (match(l:line, '<>$') != -1)
      return 'react-fragment'
    endif
    " TODO: search previous lines for tag name using searchpair()
    return ''
  endif
  let l:tagname = l:matchlist[1]
  return l:tagname
endfun

nnoremap <silent> yoS :ShutterToggle<CR>
command! ShutterToggle call s:toggle()
let s:is_enabled=0
fun! s:toggle()
  if (s:is_enabled)
    call s:disable()
  else
    call shutter#enable(0)
  endif
endfun

nnoremap [oS :ShutterEnable<CR>
command! ShutterEnable call shutter#enable(0)
fun! shutter#enable(shush)
  let s:is_enabled=1
  inoremap <expr> >           <SID>MaybeCloseTag()
  inoremap <expr> <CR>        MaybeSplitTagOrPair()
  inoremap <expr> "           <SID>StartOrCloseSymmetricPair('"')
  inoremap <expr> '           <SID>StartOrCloseSymmetricPair("'")
  inoremap <expr> `           <SID>StartOrCloseSymmetricPair("`")
  inoremap        (           <c-r>=StartPair('(', ')')<CR>
  inoremap        )           <c-r>=ClosePair2('(', ')')<CR>
  inoremap        <space>     <c-r>=StretchPair()<CR>
  inoremap        {           <c-r>=StartPair('{', '}')<CR>
  inoremap        [           <c-r>=StartPair('[', ']')<CR>
  inoremap        ]           <c-r>=ClosePair2('[', ']')<CR>
  inoremap        }           <c-r>=ClosePair2('{', '}')<CR>
  inoremap <expr> <backspace> <SID>Backspace()
  " imap <expr> <Del> <SID>Delete() " doesn't work with c-d?
  if !a:shush
    echo 'shutter enabled'
  endif
endfun
" call shutter#enable(1)
nnoremap ]oS :ShutterDisable<CR>
command! ShutterDisable call s:disable()
fun! s:disable()
  if (!s:is_enabled)
    echo 'shutter already disabled'
    return
  endif
  let s:is_enabled = 0
  iunmap >
  imap <CR> <CR><Plug>DiscretionaryEnd
  iunmap "
  iunmap '
  iunmap `
  iunmap (
  iunmap )
  iunmap <space>
  iunmap {
  iunmap [
  iunmap ]
  iunmap }
  iunmap <backspace>
  echo 'shutter disabled'
endfun

fun! StretchPair()
  call s:hideMappingMessage()
  let l:textAtOffset = getline('.')[col('.')-1-1:]

  " insert double space
  for l:splitter in s:config.symmetric_spacing
    if (exists('l:splitter.patternAtOffset') && -1 !=# match(l:textAtOffset, '^' . l:splitter.patternAtOffset))
      let l:newlinecontent = getline('.')[0:col('.')-2] . ' ' . getline('.')[col('.')-1:-1]
      call setline('.', l:newlinecontent)
      return ' '
    endif
  endfor

  " always insert space nomrally when preceding char is a comma
  if (s:stringRelativeToCursor(-1,0) ==# ',')
    return ' '
  endif

  " if 1 space from a bracket char, move cursor right without inserting
  if (s:includes([' }', ' )'], s:stringRelativeToCursor(0,2)))
    let l:newlinecontent = getline('.')[0:col('.')-2] . getline('.')[col('.')-0:-1]
    call setline('.', l:newlinecontent)
    return ' '
  endif

  return ' '
endfun

fun! s:hideMappingMessage()
  " we could just add <silent> to the mapping, but that causes the cursor to
  " spasm in the terminal (but not for nvim)
  echo ''
endfun

fun! <SID>StartOrCloseSymmetricPair(BHS)
  let l:char = s:charUnderCursor()
  if (l:char ==# a:BHS)
    return "\<Right>"
  end
  " do nothing if there's an odd number of BHS characters in this line
  if (((len(split(' ' . getline('.') . ' ', a:BHS))-1) % 2) == 1)
    return a:BHS
  endif
  " do nothing if we're touching letters on the RHS
  if (match(s:charAfterCursor(), '\S') != -1)
    return a:BHS
  else
    call s:debug('char after cursor ' . s:charAfterCursor())
  endif
  " do nothing if we're touching letters on the LHS (as in "Don't")
  if (match(s:charBeforeCursor(), '\w') != -1)
    return a:BHS
  endif
  " do nothing for vimscript comments
  if (a:BHS ==# '"' && &filetype ==# 'vim' )
    " -1 != match(getline('.')[col('.')], '^\s*$')
    call s:debug('vimscript comment')
    return '"'
  endif
  return a:BHS . a:BHS . "\<Left>"
endfun

fun! StartPair(LHS, RHS)
  call s:hideMappingMessage()
  let l:char = s:charUnderCursor()
  let l:nextchar = s:charAfterCursor()
  call s:debug('nextchar ' . l:nextchar)

  if (match(l:char, "^[0-9a-zA-Z\"']$") == 0)
    call s:debug('match blacklist character')
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
  let l:matchCountA = s:moveToNextOfPair(a:LHS, a:RHS)
  let l:posA = getpos('.')[1:]
  let l:posB = ''
  if (l:matchCountA > 0 || l:char == a:RHS)
    call s:debug('count a ' . l:matchCountA)
    let l:matchCountB = s:moveToPrevOfPair(a:LHS, a:RHS)
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
  call s:debug('posA ' . string(l:posA) . ' posB ' . string(l:posB) . ' countA ' . l:matchCountA)
  return a:LHS
endfun
fun! ClosePair2(LHS, RHS)
  call s:hideMappingMessage()
  if (s:charUnderCursor() !=# a:RHS)
    return a:RHS
  endif
  if (s:charUnderCursor() ==# a:RHS)
    let l:pos = getpos('.')[1:]
    let l:matchCount = s:moveToPrevOfPair(a:LHS, a:RHS)
    call s:debug('match count ' . string(l:matchCount) . ' - ' . a:LHS . ', ' . a:RHS)
    if (l:matchCount > 0)
      call s:debug('before ' . getline('.')[0:col('.')-2])
      call s:debug('after ' . getline('.')[col('.')-0:-1])

      " EXPERIMENTAL: see if the NEXT pair start is missing a pair end, then
      " we DON'T skip insert
      let l:matchCount = s:moveToPrevOfPair(a:LHS, a:RHS)
      if (l:matchCount > 0)
        let l:matchCount = s:moveToNextOfPair(a:LHS, a:RHS)
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
fun! <SID>ClosePair(LHS, RHS)
  " do nothing we're not typing over an existing RHS
  if (s:charUnderCursor() !=# a:RHS)
    return a:RHS
  endif
  if (s:charUnderCursor() ==# a:RHS)
    let l:pos = getpos('.')[1:]
    let l:matchCount = s:moveToPrevOfPair(a:LHS, a:RHS)
    call cursor(l:pos)
    call s:debug('match count ' . string(l:matchCount) . ' - ' . a:LHS . ', ' . a:RHS)
    if (l:matchCount > 0)
      return "\<right>"
    endif
  endif
  return a:RHS
endfun

fun! <SID>Backspace()
  let l:line = getline('.')
  for l:pattern in ['^()', '^[]', '^{}', '^""', "^''", "^``"]
    if (-1 !=# match(l:line, l:pattern, col('.')-2))
      call s:debug('DELETE2')
      return "\<delete>\<backspace>"
    endif
  endfor
  for l:pattern in ['^(  )', '^[  ]', '^{  }']
    if (-1 !=# match(l:line, '\M' . l:pattern, col('.')-3))
      call s:debug('DELETE')
      return "\<delete>\<backspace>"
    endif
  endfor
  call s:debug('normal backspace')
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

fun! s:charUnderCursor()
  return s:stringRelativeToCursor(0, 1)
  " return getline('.')[col('.')-1]
endfun
fun! s:charBeforeCursor()
  return s:stringRelativeToCursor(-1, 0)
  " return getline('.')[col('.')-2]
endfun
fun! s:charAfterCursor()
  return s:stringRelativeToCursor(1, 2)
  " return getline('.')[col('.')]
endfun
fun! s:stringRelativeToCursor(startOffset, endOffset)
  let l:cursor = col('.')-1
  let l:start = l:cursor + a:startOffset
  let l:end = l:cursor + a:endOffset - 1
  if ((l:start) < 0)
    let l:start = 0
  end
  return getline('.')[l:start:l:end]
endfun

fun! s:includes(haystack, needle)
  for l:hay in a:haystack
    if (l:hay) == a:needle
      return v:true
    endif
  endfor
  return v:false
endfun

" TODO I don't think this is working
fun! MaybeSplitTagOrPair()
  let l:textAtOffset = getline('.')[col('.')-1-1:]
  for l:splitter in s:config.format_on_newline
    if (exists('l:splitter.patternAtOffset') && -1 !=# match(l:textAtOffset, l:splitter.patternAtOffset))
      " We do not insert a tab character because filetype's indent file is
      " responsible for correctly indenting this
      return "\<CR>\<c-o>O"
    endif
  endfor

  if exists('*EndwiseDiscretionary')
    return "\<CR>\<C-R>=EndwiseDiscretionary()\<CR>"
  else
    return "\<CR>"
  endif
endfun

fun! s:moveToNextOfPair(LHS, RHS)
  return searchpair('\M' . a:LHS, '', a:RHS, 'Wm', '', line('w$'))
endfun

fun! s:moveToPrevOfPair(LHS, RHS)
  return searchpair('\M' . a:LHS, '', a:RHS, 'Wmb', '', line('w0'))
endfun
