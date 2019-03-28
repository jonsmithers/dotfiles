" dotfile_extras.vim - Optional/deferred vim configurations 
" (see :help autoload)
" Author:       Jon Smithers <mail@jonsmithers.link>
" URL:          https://github.com/jonsmithers/dotfiles/blob/master/vim/dotfile_extras.vim
" Last Updated: 2019-03-28

if (!exists('s:dotfile_extras_script'))
  let s:dotfile_extras_script = expand('<sfile>')
  autocmd BufWritePost dotfile_extras.vim exec 'source ' . s:dotfile_extras_script
endif

function! dotfile_extras#MakeEslint(targets)
  let l:targets = expand(a:targets)
  if (len(l:targets) == 0)
    let l:targets = './'
  endif
  set errorformat+=%f:\ line\ %l\\,\ col\ %c\\,\ %trror\ -\ %m
  set errorformat+=%f:\ line\ %l\\,\ col\ %c\\,\ %tarning\ -\ %m
  if (executable('yarn'))
    set makeprg=yarn\ exec\ eslint\ --\ --format\ compact
  elseif (executable('npx'))
    set makeprg=npx\ eslint\ --format\ compact
  else
    echoerr 'Both yarn and npx are missing'
    return
  endif
  echom &makeprg . ' ' . l:targets
  exec 'make! ' . l:targets
  copen
endfunction

" puts all eslint issues into quickfix list
function! dotfile_extras#rungulpeslint()
  " expects the built-in 'compact' formatter
  set errorformat+=%f:\ line\ %l\\,\ col\ %c\\,\ %trror\ -\ %m
  set errorformat+=%f:\ line\ %l\\,\ col\ %c\\,\ %tarning\ -\ %m
  set makeprg=gulp
  make eslint --machine-format
endfunction

function! dotfile_extras#ToggleScrollMode()
  if exists('s:scroll_mode')
    unmap k
    unmap j
    unmap d
    unmap u
    unlet s:scroll_mode
    echom 'scroll mode off'
  else
    nnoremap j <C-e>j
    nnoremap k <C-y>k
    nnoremap d <C-d>
    nnoremap u <C-u>
    let s:scroll_mode = 1
    echom 'scroll mode on'
  endif
endfunction

func! dotfile_extras#ProseMode()
  delcommand ProseMode
  com CodeMode call dotfile_extras#CodeMode()
  Goyo

  " booleans
  let b:autoindent    = &autoindent
  let b:copyindent    = &copyindent
  let b:list          = &list
  let b:showcmd       = &showcmd
  let b:showmode      = &showmode
  let b:smartindent   = &smartindent
  let b:spell         = &spell

  " non-booleans
  let b:complete      = &complete
  let b:formatoptions = &formatoptions
  let b:formatlistpat = &formatlistpat
  let b:sidescrolloff = &sidescrolloff
  let b:whichwrap     = &whichwrap

  setlocal nocopyindent nolist noshowcmd noshowmode nosmartindent spell
  setlocal complete+=s formatoptions=tcq formatoptions+=an sidescrolloff=0 whichwrap+=h,l
  "        ^ complete from thesarus
  "                    ^ default formatoptions
  "                                      ^ add Auto-format and Numbered lists

  set autoindent " appears necessary to have paragraph formatting keep indent past the 2nd line

  augroup prosemode
    autocmd ColorScheme * hi EndOfBuffer ctermfg=bg guifg=bg
    " hide "~" at end of buffer
  augroup END

  DarkSacredForest
  nnoremap <leader><leader> :silent w<cr>:redraw!<cr>

  highlight link EntryDateLine Comment
  match EntryDateLine /^\w\w\w \w\w\w \d\d\? \d\d\d\d \d\d\?:\d\d:\d\d \?\(AM\|PM\)\?$/
endfu
if (!exists('*dotfile_extras#CodeMode')) " this function sources vimrc and you can't redefine function while it's executing
  func dotfile_extras#CodeMode()
    delcommand CodeMode
    com ProseMode call dotfile_extras#ProseMode()

    " unhide "~" at end of buffer
    hi clear EndOfBuffer
    hi link EndOfBuffer NonText

    augroup prosemode
      autocmd!
    augroup END
    augroup! prosemode

    Goyo!
    exec 'setlocal ' . (b:autoindent  ? '':'no') . 'autoindent'
    exec 'setlocal ' . (b:copyindent  ? '':'no') . 'copyindent'
    exec 'setlocal ' . (b:list        ? '':'no') . 'list'
    exec 'setlocal ' . (b:showcmd     ? '':'no') . 'showcmd'
    exec 'setlocal ' . (b:showmode    ? '':'no') . 'showmode'
    exec 'setlocal ' . (b:smartindent ? '':'no') . 'smartindent'
    exec 'setlocal ' . (b:spell       ? '':'no') . 'spell'
    exec 'setlocal complete='     .b:complete
    exec 'setlocal formatoptions='.b:formatoptions
    exec 'setlocal sidescrolloff='.b:sidescrolloff
    exec 'setlocal whichwrap='    .b:whichwrap
    source $MYVIMRC
  endfu
endif


" I very rarely use this because scrolling can get really funky (a paragraph
" is either all-visible or all-hidden. It's still nice to have for when you
" need to read long paragraphs in vim.
func! dotfile_extras#SoftWrappedProcessorMode()
  Goyo 80
  setlocal nonumber
  setlocal noexpandtab
  setlocal wrap
  setlocal linebreak
  setlocal breakindent
  map <buffer> j gj
  map <buffer> k gk
  " setlocal formatprg=par -jw80
  "setlocal spell spelllang=en_us
  "set thesaurus+=/Users/sbrown/.vim/thesaurus/mthesaur.txt
  "set complete+=s
endfu

" visor style terminal buffer
  " https://www.reddit.com/r/neovim/comments/3cu8fl/quick_visor_style_terminal_buffer/
if (!exists('s:termbuf'))
  let s:termbuf = 0
endif
function! dotfile_extras#ToggleTerm()

  "normal mx
  "normal H
  botright 20 split
  "wincmd p
  "normal `x
  "wincmd p

  if (s:termbuf && bufexists(s:termbuf))
    exe 'buffer' . s:termbuf
  else
    echom s:termbuf . ' does not exist'
    terminal ++curwin
    let s:termbuf=bufnr('%')
    "tnoremap <buffer> <F4> <C-\><C-n>:close<cr>
    tnoremap <buffer> <F4> <C-w><C-q>
    nnoremap <buffer> <F4> i<C-w><C-q>
    vnoremap <buffer> <F4> <esc>i<C-w><C-q>
  endif
endfunction
