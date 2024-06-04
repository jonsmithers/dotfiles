" vim: ts=2 sw=2
" Last Updated: 2024-06-04


if !exists('s:os')
  if has('win64') || has('win32') || has('win16')
    let s:os = 'Windows'
  elseif has('mac')
    let s:os = 'MacOS'
  else
    let s:os = 'Linux'
  endif
endif

if (s:os ==# 'Windows')
  set encoding=utf-8
endif

nnoremap <leader>; :
vnoremap <leader>; :
nnoremap <leader>= :=

" search and replace (works well with Traces.vim)
vnoremap <c-r>A y:call g:ReplaceAppend()<cr>
vnoremap <c-r>c y:call g:ReplaceChange()<cr>
vnoremap <c-r>I y:call g:ReplaceInsert()<cr>
fun! g:ReplaceAppend()
  let l:selection = escape(@0, '/\')
  call feedkeys(":%substitute/\\V\\C" . l:selection . '/' . l:selection . "/gc\<left>\<left>\<left>")
  return ''
endfun
fun! g:ReplaceChange()
  let l:selection = escape(@0, '/\')
  call feedkeys(":%substitute/\\V\\C" . l:selection . '/' . "/gc\<left>\<left>\<left>")
  return ''
endfun
fun! g:ReplaceInsert()
  let l:selection = escape(@0, '/\')
  call feedkeys(":%substitute/\\V\\C" . l:selection . '/' . l:selection . "/gc\<left>\<left>\<left>" . repeat("\<left>", len(l:selection)))
  return ''
endfun
" insert ISO date in : menu
cnoremap <c-x><c-d> <c-r>=strftime('%Y-%m-%d')<cr>
inoremap <c-x><c-d> <c-r>=strftime('%Y-%m-%d')<cr>
inoremap jk <Esc>
" https://castel.dev/post/lecture-notes-1/
inoremap <c-l> <c-g>u<Esc>[s1z=`]a<c-g>u
" clear search
nnoremap <silent> <leader>sdf :let @/ = ''<cr>

" horizontal scroll
nnoremap <C-h> 5zh
nnoremap <C-l> 5zl

" quick save
nnoremap <silent> <Leader><Leader> :update<Enter>

" switch with most recent buffer
nnoremap <Leader><Tab> :b#<enter>

command! FormatJSON :%!python3 -m json.tool
command! FormatXML :%!python3 -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"

command! OpenInVSCode    exe "silent !code --goto '" . expand("%") . ":" . line(".") . ":" . col(".") . "'"                    | redraw!
command! OpenCwdInVSCode exe "silent !code '" . getcwd() . "' --goto '" . expand("%") . ":" . line(".") . ":" . col(".") . "'" | redraw!
command! OpenInIdea      exe "silent !idea '" . getcwd() . "' --line " . line(".") . " --column " . (col(".")-1) . " '" . expand("%") . "'"                  | redraw!
command! Quit2Idea       exe "silent !idea '" . getcwd() . "' --line " . line(".") . " --column " . (col(".")-1) . " '" . expand("%") . "'"                  | redraw! | quit
if has('nvim')
  nnoremap <leader>gi :execute "!                idea '" . getcwd() . "' --line " . line(".") . " --column " . (col(".")-1) . " '" . expand("%") . "'"<cr>
else
  nnoremap <leader>gi :execute "terminal ++close idea '" . getcwd() . "' --line " . line(".") . " --column " . (col(".")-1) . " '" . expand("%") . "'"<cr>
endif

func! OpenUrl()
  exec '!python3 -m webbrowser "' . matchstr(getline('.'), 'https\?://[a-zA-Z0-9\./\-?=\&+@,!:_#%*;:~]\+[^,.) \"]').'"' | redraw!
endfu
com! TestUrl exec 'echom  "'.       matchstr(getline('.'), 'https\?://[a-zA-Z0-9\./\-?=\&+@,!:_#%*;:~]\+[^,.) \"]').'"'
nnoremap <Leader>ou :call OpenUrl()<Enter>

func! s:HighlightTrailingSpace()
  highlight TrailingSpace ctermbg=red ctermfg=white guibg=#592929
  match TrailingSpace /\s\+\n/
endfu
command! TrailingSpaceHighlight call s:HighlightTrailingSpace()
command! TrailingSpaceDeleteAll :%s/\s\+\n/\r/gc
func! HighlightOverlength()
  highlight OverLength ctermbg=red ctermfg=white guibg=#592929
  match OverLength /\%81v.\+/
endfu

fun! g:Redir(cmd)
  " https://iamsang.com/en/2022/04/13/vimrc/
  redir => l:message
  silent execute a:cmd
  redir END
  if empty(l:message)
    echoerr "no output"
  else
    tabnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    silent put=l:message
  endif
endfunction
command! -nargs=+ -complete=command Redir call g:Redir(<q-args>)

" Change Cursor Style Dependent On Mode: https://github.com/mhinz/vim-galore#change-cursor-style-dependent-on-mode {{{
  " https://stackoverflow.com/a/42118416/1480704
  if empty($ITERM_PROFILE)
    " seems to work everywhere but iTerm
    let &t_SI = "\e[6 q"
    let &t_EI = "\e[2 q"
    let &t_SR = "\e[3 q"
  else
    if empty($TMUX)
      let &t_SI = "\<Esc>]50;CursorShape=1\x7"
      let &t_EI = "\<Esc>]50;CursorShape=0\x7"
      let &t_SR = "\<Esc>]50;CursorShape=2\x7"
    else
      let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
      let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
      let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
    end
  end
  let s:is_neovide = has('nvim') && exists('g:neovide')
  if (s:is_neovide)

    " Allow copy paste in neovide (https://github.com/neovide/neovide/issues/1263)
    let g:neovide_input_use_logo = 1
    map <D-v> "+p<CR>
    map! <D-v> <C-R>+
    tmap <D-v> <C-R>+
    vmap <D-c> "+y<CR>
  endif

" }}}

augroup vim_startup
  au!
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid, when inside an event handler
  " (happens when dropping a file on gvim) and for a commit message (it's
  " likely a different one than last time).
  autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ |   exe "normal! g`\""
        \ | endif

augroup END
set ignorecase    "search ignores case
set smartcase     "unless there's a capital letter
set shortmess+=I  "disable intro :intro
set mouse=a
set nowrap
set number
set autoindent
set nosmartindent
set noswapfile
set splitbelow    " more natural split behavior
set splitright    " more natural split behavior
set termguicolors

set expandtab     " SPACES over TABS
set smarttab      " delete multiple spaces at once (as if deleting a tab character)
com! -nargs=1 Tab      set      tabstop=<args> | set      shiftwidth=<args> "| set softtabstop=<args>
com! -nargs=1 LocalTab setlocal tabstop=<args> | setlocal shiftwidth=<args> "| set softtabstop=<args>

" set wildignore=**/node_modules/**
set directory=/var/tmp//,/tmp//,.
if (has('nvim'))
  set cmdheight=0
  let $GIT_EDITOR='nvim'
  let $EDITOR='nvim'
  " Avoid launching vim from within neovim, because neovim has a bug where
  " it sets environment vars that cause vim to print errors on startup.
endif

if (s:os !=# 'Windows')

  set backupdir=/var/tmp//
  set backup
  " 'backupskip=/tmp/*' is set by default

  command! Backups     call <sid>DiffWithBackup()
  nnoremap <leader>bd :call <sid>DiffWithBackup()<cr>

  augroup vimrc_backup
    autocmd!
    au BufWritePre * let &backupext = '-' . strftime("%Y%m%d-%H%M%S") . '.vimbackup'
  augroup END

  fun! <sid>DiffWithBackup()
    let l:fzfSelectables = []
    for l:backupDir in split(&backupdir, ',')
      let l:basePath = l:backupDir
      if (l:backupDir[-2:] == '//')
        let l:basePath = l:basePath[:-2]
        let l:basePath .= substitute(expand('%:p'), '/', '%', 'g')
      else
        if (l:backupDir[-1:] != '/')
          let l:basePath .= '/'
        endif
        let l:basePath .= expand('%:t')
      endif
      let l:newBackupFiles = sort(split(glob(l:basePath . '-*.vimbackup'), '\n'))

      fun! s:toUserReadableFormat(filepath, basePath)
        let l:result = a:filepath
        let l:result = substitute(l:result, '\V' . a:basePath, '', '')
        let l:result = substitute(l:result, '^-', '', '')
        let l:result = substitute(l:result, '.vimbackup', '', '')
        let l:year   = l:result[0:3]
        let l:month  = l:result[4:5]
        let l:day    = l:result[6:7]
        let l:hour   = l:result[09:10]
        let l:minute = l:result[11:12]
        let l:second = l:result[13:14]
        let l:result = l:year . '-' . l:month . '-' . l:day . ' ' . l:hour . ':' . l:minute . ':' . l:second
        return l:result
      endfun
      let l:fzfSelectables += map(copy(l:newBackupFiles), {-> v:val . '<<fake-delimiter>>' . s:toUserReadableFormat(v:val, l:basePath)})
    endfor
    call reverse(l:fzfSelectables)
    fun! s:backupDiffSink(selectedBackupFile)
      let l:selectedBackupFile = escape(split(a:selectedBackupFile, '<<fake-delimiter>>')[0], '%')
      diffoff!
      exec 'vertical diffsplit ' . l:selectedBackupFile
      setlocal readonly nobuflisted bufhidden=wipe buftype=nowrite noswapfile
      autocmd QuitPre <buffer> diffoff!
      autocmd BufHidden <buffer> diffoff!
      wincmd p
    endfun
    call fzf#run(fzf#wrap({
          \ 'sink': funcref('s:backupDiffSink'),
          \ 'source': l:fzfSelectables,
          \ 'options': [
          \   '--prompt', 'backup file> ',
          \   '--preview', 'git diff --color=always {1} ' . s:currentFileInSingleQuotes() . s:omitDiffHeaders,
          \   '--with-nth=2',
          \   '--delimiter=<<fake-delimiter>>'
          \ ]
          \ }))
  endfun
  fun! s:currentFileInSingleQuotes()
    return "'"..escape(expand('%'), "'").."'"
  endfun
endif

let s:omitDiffHeaders = ' | grep -v "^\[1m\(diff\|index\|+++\|---\) "'

if (!exists('g:colors_name')) " no colorscheme set
  if exists('$VIM_BACKGROUND')
    execute 'set background='..$VIM_BACKGROUND
  else
    set background=dark
  endif
  if exists('$VIM_THEME_GLOBALS')
    for assignment in split($VIM_THEME_GLOBALS, ',')
      sandbox execute 'let g:'..split(assignment, '=')[0]..'="'..split(assignment, '=')[1]..'"'
    endfor
  endif
  if exists('$VIM_COLORSCHEME')
    execute 'silent! colorscheme ' .. $VIM_COLORSCHEME
  endif
endif

augroup vimrc_autocomamnds
  autocmd!

  " custom filetype behaviors
  autocmd FileType gitcommit setlocal spell
  autocmd FileType gitcommit call s:gitcommitStartInsertIfEmpty()
  autocmd FileType gitcommit set comments+=fb:-,fb:+,fb:*
  autocmd FileType gitcommit set formatoptions+=cq
  autocmd FileType gitcommit normal gg
  " ^ workaround weird issue where caret sometimes starts 2 lines down
  autocmd FileType text     setlocal spell
  autocmd Filetype markdown setlocal spell
  " correct formatting for checklists

  autocmd Filetype markdown setlocal comments-=fb:-
  autocmd Filetype markdown setlocal comments+=fb:-\ [\ ]
  autocmd Filetype markdown setlocal comments+=fb:-\ [X]
  autocmd Filetype markdown setlocal comments+=fb:-

  let g:markdown_folding = 1 " enable folding via vim's native markdown plugin
  " let g:vimsyn_folding = 'af' " is too slow

  autocmd Filetype sh setlocal comments+=fb:#

  fun! s:gitcommitStartInsertIfEmpty()
    if (empty(getline(1)))
      startinsert!
    endif
  endfunction

  if has('nvim')
    :tnoremap <C-w> <C-\><C-n><C-w>
  endif

  " disable syntax when editing huge files so vim stays snappy
  autocmd Filetype * if (getfsize(@%) > 500000 && &filetype != "git") | setlocal syntax=OFF | endif

  autocmd Filetype javascript,html,typescript call s:ftpluginJavascripty()
  autocmd Filetype typescriptreact            call s:ftpluginJavascripty()
  autocmd Filetype lua                        call s:ftpluginLua()
  autocmd Filetype python                     nnoremap <buffer> <space>py :!python3 %<cr>
  autocmd Filetype python                     set omnifunc=pythoncomplete#Complete
  autocmd Filetype vim                        call s:ftpluginVim()

  fun! s:ftpluginVim()
    :nnoremap <buffer> <Leader>il oechom ''i
  endfunction
  fun! s:ftpluginJavascripty()
    nnoremap <buffer> <Leader>il oconsole.log();F)i
    nnoremap <buffer> <Leader>iL oconsole.log('%c', 'font-size:15px');F,hi
    nnoremap <buffer> <Leader>liw yiwoconsole.log('0', 0);<Esc>
    nnoremap <buffer> <Leader>lif yiwoconsole.log('0()');<Esc>
    nnoremap <buffer> <Leader>liF yiwoconsole.log('%c0()', 'font-size:15px');<Esc>^2w
    nnoremap <buffer> <Leader>gif yiwf{oconsole.group('0');<Esc>]}Oconsole.groupEnd();<Esc>^
    nnoremap <buffer> <Leader>jsxc 0wi{/*<Esc>$a*/}<Esc>
    nnoremap <buffer> <Leader>jsxC :s@{\/\* \?\\| \?\*/}@@g<Enter>
  endfun
  fun! s:ftpluginLua()
    nnoremap <buffer> <Leader>il ovim.print()i
    nnoremap <buffer> <Leader>liw yiwovim.print('0', 0)<Esc>
    nnoremap <buffer> <Leader>lif yiwovim.print('0()')<Esc>
    nnoremap <buffer> <Leader>liF yiwovim.print('%c0()', 'font-size:15px')<Esc>^2w
  endfun
augroup END

augroup vimrc_updatetimestamp
  au!
  autocmd BufWritePre dotphile,en.utf-8.add,git-website,init2.vim,init.lua call s:updateTimeStamp()
augroup END
function! s:updateTimeStamp()
  " ignore for fugitive files
  if (match(expand('%'), '^fugitive') == 0)
    return
  endif
  let l:save_view = winsaveview()
  let l:now = strftime('%Y-%m-%d')

  call cursor(1, 1)
  let l:matchlist = matchlist(getline(search('Last Updated', 'W', 10)), 'Last Updated: \(.*\)')
  if (!len(l:matchlist))
    call winrestview(l:save_view)
    return
  endif
  let l:lastUpdated = l:matchlist[1]
  if (l:lastUpdated ==# l:now)
    call winrestview(l:save_view)
    return
  end

  " normal <c-o>
  if (line('$') <= 10)
    silent! keeppatterns    :%s/\(^\("\|#\) Last Updated:\)\zs.*/\=' ' . l:now
  else
    silent! keeppatterns :1,10s/\(^\("\|#\) Last Updated:\)\zs.*/\=' ' . l:now
  endif
  call winrestview(l:save_view)
endfunction

let g:fugitive_gitlab_domains = ['https://git.aoc-pathfinder.cloud/']
