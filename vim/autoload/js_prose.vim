func! js_prose#ProseMode()
  delcommand ProseMode
  command -buffer CodeMode call js_prose#CodeMode()
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
  let b:filetype      = &filetype

  setlocal nocopyindent nolist noshowcmd noshowmode nosmartindent spell autoindent
  "                                                                     ^ appears necessary to have paragraph formatting keep indent past the 2nd line
  setlocal complete+=s formatoptions=tcq formatoptions+=an formatoptions+=ro sidescrolloff=0 whichwrap+=h,l
  "        ^ complete from thesarus
  "                    ^ default formatoptions
  "                                      ^ add Auto-format and Numbered lists
  "                                                        ^ insert comment leader for <cr> and "                                      o

  augroup prosemode
    au!
    autocmd ColorScheme <buffer> hi EndOfBuffer ctermfg=bg guifg=bg
    " hide "~" at end of buffer
  augroup END

  " Plugins that add a <cr> mapping (like vim-endwise) probably don't make it
  " <buffer> mapping, so this buffer mapping won't destroy it.
  inoremap <buffer> <cr> <cr><cr>

  " LightGitHub
  " DarkSacredForest
  " nnoremap <leader><leader> :silent w<cr>:redraw!<cr>

  set filetype=sjournal
endfu
if (!exists('*js_prose#CodeMode')) " this function sources vimrc and you can't redefine function while it's executing
  func js_prose#CodeMode()
    delcommand CodeMode
    com ProseMode call js_prose#ProseMode()

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
    exec 'setlocal filetype='     .b:filetype

    iunmap <buffer> <cr>

    source $MYVIMRC
  endfu
endif
fun! js_prose#ToggleProseMode()
  if (exists(':ProseMode'))
    ProseMode
  else
    CodeMode
  endif
endfun


" I very rarely use this because scrolling can get really funky (a paragraph
" is either all-visible or all-hidden. It's still nice to have for when you
" need to read long paragraphs in vim.
func! js_prose#SoftWrappedProcessorMode()
  Goyo 80
  setlocal nonumber
  setlocal noexpandtab
  setlocal wrap
  setlocal linebreak
  setlocal breakindent
  setlocal nolist
  map <buffer> j gj
  map <buffer> k gk
  map <buffer> $ g$
  map <buffer> 0 g0
  map <buffer> ^ g^
  nnoremap <buffer> A g$i
  nnoremap <buffer> I g0i
  " setlocal formatprg=par -jw80
  "setlocal spell spelllang=en_us
  "set thesaurus+=/Users/sbrown/.vim/thesaurus/mthesaur.txt
  "set complete+=s
endfu

