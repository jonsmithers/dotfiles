" {{{ gx to open GitHub urls in browser
  function! s:plug_gx()
    let l:line = getline('.')
    let l:sha  = matchstr(l:line, '^  \X*\zs\x\{7,9}\ze ')
    let l:name = empty(l:sha) ? matchstr(l:line, '^[-x+] \zs[^:]\+\ze:')
                        \ : getline(search('^- .*:$', 'bn'))[2:-2]
    let l:uri  = get(get(g:plugs, l:name, {}), 'uri', '')
    if l:uri !~? 'github.com'
      return
    endif
    let l:repo = matchstr(l:uri, '[^:/]*/'.l:name)
    let l:url  = empty(l:sha) ? 'https://github.com/'.l:repo
                        \ : printf('https://github.com/%s/commit/%s', l:repo, l:sha)
    call netrw#BrowseX(l:url, 0)
  endfunction

  augroup PlugGx
    autocmd!
    autocmd FileType vim-plug nnoremap <buffer> <silent> gx :call <sid>plug_gx()<cr>
  augroup END
" }}}

" {{{ Extra key bindings for PlugDiff
  function! s:scroll_preview(down)
    silent! wincmd P
    if &previewwindow
      execute 'normal!' a:down ? "\<c-e>" : "\<c-y>"
      wincmd p
    endif
  endfunction

  function! s:setup_extra_keys()
    nnoremap <silent> <buffer> J :call <sid>scroll_preview(1)<cr>
    nnoremap <silent> <buffer> K :call <sid>scroll_preview(0)<cr>
    nnoremap <silent> <buffer> <c-n> :call search('^  \X*\zs\x')<cr>
    nnoremap <silent> <buffer> <c-p> :call search('^  \X*\zs\x', 'b')<cr>
    nmap <silent> <buffer> <c-j> <c-n>o
    nmap <silent> <buffer> <c-k> <c-p>o
  endfunction

  augroup PlugDiffExtra
    autocmd!
    autocmd FileType vim-plug call s:setup_extra_keys()
  augroup END
" }}}

" {{{ Browse help files and readme
  command! PlugHelp call fzf#run(fzf#wrap({
    \ 'source': sort(keys(g:plugs)),
    \ 'sink':   function('s:plug_help_sink')}))

  function! s:plug_help_sink(line)
    let l:dir = g:plugs[a:line].dir
    for l:pat in ['doc/*.txt', 'README.md']
      let l:match = get(split(globpath(l:dir, l:pat), "\n"), 0, '')
      if len(l:match)
        execute 'tabedit' l:match
        return
      endif
    endfor
    tabnew
    execute 'Explore' l:dir
  endfunction
" }}}

" vim:foldmethod=marker:
