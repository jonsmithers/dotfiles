set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" TODO does this actually work?
" https://www.reddit.com/r/neovim/comments/j3xmf3/how_can_i_highlight_lua_code_in_a_usual_vim_file/
let g:vimsyn_embed= 'l'

" TODO move this into a lua file plugins.lua
fun! SetupDirectorySpecificConfiguration()
lua << EOF
  on_dir_changed = function()
    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ':~:.') -- relative to and including "~"
    if DirectoryConfiguration ~=nil and DirectoryConfiguration[cwd] ~= nil then
      DirectoryConfiguration[cwd]()
    end
  end
EOF

  if (!empty(glob("~/.config/nvim/profile.lua")))
    " this file may create a DirectoryConfiguration lua object
    "   DirectoryConfiguration = {
    "     ["~"] = function()
    "     end,
    "     ["~/git/dotfiles"] = function()
    "     end,
    "   }
    source ~/.config/nvim/profile.lua

    augroup nvim_lsp_file
      autocmd!
      autocmd DirChanged * lua on_dir_changed()
    augroup end
    if v:vim_did_enter
      lua on_dir_changed()
    else
      autocmd VimEnter * lua on_dir_changed()
    endif
  endif
endfun

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

