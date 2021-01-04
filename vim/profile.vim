Plug 'nathangrigg/vim-beancount'
" {{{
augroup vimrc_beancount
  au!
  autocmd FileType beancount let b:beancount_root='main.beancount'
augroup END

augroup vimrc_beancount2
  au!
  autocmd FileType beancount command! -buffer BeancountFormat call <SID>FormatBeancountFile()
augroup END

fun! <SID>FormatBeancountFile()
  diffoff
  let l:file = expand('%')
  vnew
  exec 'read ! bean-format '.l:file
  normal ggdd
  let &filetype='beancount'
  setlocal readonly nomodified nobuflisted bufhidden=delete buftype=nofile noswapfile
  autocmd QuitPre <buffer> diffoff!
  autocmd BufHidden <buffer> diffoff!
  diffthis
  wincmd p
  diffthis
endfun

let g:markdown_fenced_languages += ['beancount']
" }}}
