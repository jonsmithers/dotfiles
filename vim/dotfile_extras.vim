" dotfile_extras.vim - Optional/deferred vim configurations 
" (see :help autoload)
" Author:       Jon Smithers <mail@jonsmithers.link>
" URL:          https://github.com/jonsmithers/dotfiles/blob/master/vim/dotfile_extras.vim
" Last Updated: 2019-08-23

if (!exists('s:dotfile_extras_script'))
  let s:dotfile_extras_script = expand('<sfile>')
  autocmd BufWritePost dotfile_extras.vim exec 'source ' . s:dotfile_extras_script
endif

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
    if has('nvim')
      terminal
      startinsert
    else
      terminal ++curwin
    endif
    let s:termbuf=bufnr('%')
    "tnoremap <buffer> <F4> <C-\><C-n>:close<cr>
    tnoremap <buffer> <F4> <C-w><C-q>
    nnoremap <buffer> <F4> i<C-w><C-q>
    vnoremap <buffer> <F4> <esc>i<C-w><C-q>
  endif
endfunction
