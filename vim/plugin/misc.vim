" dotfile_extras.vim - Optional/deferred vim configurations 
" (see :help autoload)
" Author:       Jon Smithers <jon@smithers.dev>
" URL:          https://github.com/jonsmithers/dotfiles/blob/master/vim/dotfile_extras.vim
" Last Updated: 2021-11-28

" re-source this script when I change it
if (!exists('s:misc_script'))
  exec 'autocmd BufWritePost ' . expand('<sfile>:t') . ' exec "source ' . expand('<sfile>') . '"'
endif

" alternate scroll mode {{{
  nnoremap zs 0zz:call <SID>ToggleScrollMode()<Enter>
  function! <SID>ToggleScrollMode()
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
" }}}

" vim:foldmethod=marker:
