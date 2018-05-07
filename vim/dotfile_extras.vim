" these functions aren't loaded at startup, but only when they are invoked
" (see :help autoload)

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
  Goyo
  let b:spell         = &spell
  let b:copyindent    = &copyindent
  let b:autoindent    = &autoindent
  let b:list          = &list
  let b:showmode      = &showmode
  let b:showcmd       = &showcmd
  let b:formatoptions = &formatoptions
  let b:whichwrap     = &whichwrap
  let b:sidescrolloff = &sidescrolloff

  setlocal spell
  setlocal nocopyindent noautoindent nolist noshowmode noshowcmd
  setlocal complete+=s " complete from thesaurus
  setlocal formatoptions=an
  setlocal whichwrap+=h,l
  setlocal sidescrolloff=0
  LightOne " setlocal bg=light
  hi SpellBad guibg=pink guifg=red
  " my terminals don't undercurl, as termguicolor would have them do, so
  " mispelled words must be highlighted
  hi EndOfBuffer ctermfg=bg guifg=bg
  " hide "~" at end of buffer
endfu
if (!exists('*dotfile_extras#CodeMode')) " this function sources vimrc and you can't redefine function while it's executing
  func dotfile_extras#CodeMode()
    Goyo!
    exec 'setlocal ' . (b:spell      ? '':'no') . 'spell'
    exec 'setlocal ' . (b:copyindent ? '':'no') . 'copyindent'
    exec 'setlocal ' . (b:autoindent ? '':'no') . 'autoindent'
    exec 'setlocal ' . (b:list       ? '':'no') . 'list'
    exec 'setlocal ' . (b:showmode   ? '':'no') . 'showmode'
    exec 'setlocal ' . (b:showcmd    ? '':'no') . 'showcmd'
    exec 'setlocal formatoptions='.b:formatoptions
    exec 'setlocal whichwrap='    .b:whichwrap
    exec 'setlocal sidescrolloff='.b:sidescrolloff
    source $MYVIMRC
  endfu
endif


" I very rarely use this because scrolling can get really funky (a paragraph
" is either all-visible or all-hidden. It's still nice to have for when you
" need to read long paragraphs in vim.
func! dotfile_extras#SoftWrappedProcessorMode()
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
com! SoftWrapMode call SoftWrappedProcessorMode()

let s:termbuf = 0
function! dotfile_extras#ToggleTerm()
  topleft 30 split
  try
    exe 'buffer' . s:termbuf
    startinsert
  catch
    terminal
    let s:termbuf=bufnr('%')
    tnoremap <buffer> <A-t>  <C-\><C-n>:close<cr>
  endtry
endfunction
