set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" TODO does this actually work?
" https://www.reddit.com/r/neovim/comments/j3xmf3/how_can_i_highlight_lua_code_in_a_usual_vim_file/
let g:vimsyn_embed= 'l'

lua << EOF
  require('plugins')
EOF

" https://www.reddit.com/r/neovim/comments/nrz9hp/can_i_close_all_floating_windows_without_closing/
:lua << EOF
  function CloseFloatingWindows()
    for _, win in ipairs(vim.api.nvim_list_wins()) do 
      local config = vim.api.nvim_win_get_config(win);
      if config.relative ~= "" then vim.api.nvim_win_close(win, false);
        print('Closing window', win) 
      end
    end
  end
EOF
com! CloseFloatingWindows lua CloseFloatingWindows()

