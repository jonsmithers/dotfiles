Plug 'nathangrigg/vim-beancount'
" {{{
augroup vimrc_beancount
  au!
  autocmd FileType beancount let b:beancount_root='main.beancount'
augroup END
let g:markdown_fenced_languages += ['beancount']
" }}}
