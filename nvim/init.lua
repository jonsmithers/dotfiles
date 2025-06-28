-- vim: ts=2 sw=2
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ Author: Jon Smithers <jon@smithers.dev>                                 │
-- │ URL:    https://github.com/jonsmithers/dotfiles/blob/main/nvim/init.lua │
-- └─────────────────────────────────────────────────────────────────────────┘

vim.opt.breakindent = true
vim.opt.undofile = true

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' '
vim.cmd.source(vim.env.HOME .. '/.config/nvim/init2.vim')
-- vim.cmd.source(vim.env.HOME .. '/.config/nvim/kitty.lua')
vim.cmd.source(vim.env.HOME .. '/.config/nvim/terminal.lua')

vim.api.nvim_create_augroup('init.lua', {})
local dev_icons_enabled = os.getenv('VIM_DEVICONS') == '1'

local deno_dirs = {
  -- (insert deno dirs)
}
local is_deno_dir = vim.tbl_contains(deno_dirs, vim.fn.getcwd());

vim.g.maplocalleader = '\\'

-- ┌─────────┐
-- │ PLUGINS │
-- └─────────┘
-- plugins stored in ~/.local/share/nvim/lazy/
require('lazy').setup('plugins')

-- https://www.reddit.com/r/neovim/comments/nrz9hp/can_i_close_all_floating_windows_without_closing/
function CloseFloatingWindows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win);
    if config.relative ~= "" then vim.api.nvim_win_close(win, false);
      print('Closing window', win)
    end
  end
end
vim.cmd[[
  com! CloseFloatingWindows lua CloseFloatingWindows()
  nnoremap <silent> <leader>dc :silent CloseFloatingWindows<cr>
]]

vim.opt.foldlevelstart = tonumber(vim.env['NVIM_OPT_FOLDLEVELSTART']) or 99
vim.opt.relativenumber = 'true' == vim.env['NVIM_OPT_RELATIVENUMBER']

vim.opt.title = true
vim.o.titlestring = ""
vim.api.nvim_create_autocmd({'BufEnter', 'TermEnter'}, {
  pattern = '*',
  group = 'init.lua',
  callback = function()
    if (vim.g.vscode) then
      return
    end
    -- local cwd = "  %{fnamemodify(getcwd(), ':t')}  "
    local cwd = "  %{fnamemodify(getcwd(), ':t')}/"
    if (vim.o.filetype == 'snacks_picker_input') then
      vim.o.titlestring = cwd..''
    elseif (vim.fn.expand('%') == '') then
      vim.o.titlestring = cwd..''
    elseif (vim.o.filetype == 'NvimTree') then
      vim.o.titlestring = cwd..''
    elseif (vim.o.filetype == 'oil') then
      vim.o.titlestring = cwd..''
    elseif (vim.o.filetype == 'fugitive') then
      vim.o.titlestring = cwd..''
    elseif (string.find(vim.fn.expand('%'), 'FZF')) then
      vim.o.titlestring = cwd..''
    else
      -- vim.o.titlestring = cwd.."%{expand('%:t')}:%l"
      local icon = require'nvim-web-devicons'.get_icon(vim.fn.expand('%:t:r'), vim.fn.expand('%:t:e'))
      local maybe_space = (icon and ' ' or '')
      vim.o.titlestring = cwd.."%{expand('%:t:r')}"..maybe_space..(icon or '')..(maybe_space)
    end
  end
})

-- draw a box around text
-- memonic: "you surround til $ with _"
vim.keymap.set('n', 'ys$_', function()
  local x = vim.fn.col('.')
  vim.cmd.normal('i│ ')
  vim.cmd.normal('A │')
  vim.cmd.normal('yyP'..x..'|r┌lv$hhr─$r┐j')
  vim.cmd.normal('p'..x..'|r└lv$hhr─$r┘k')
  vim.cmd.normal('|'..x..'ll')
end)

if (vim.g.vscode) then
  vim.cmd[[
    nnoremap ]d <Cmd>lua require('vscode').action('editor.action.marker.next')<CR>
    nnoremap [d <Cmd>lua require('vscode').action('editor.action.marker.prev')<CR>
    nnoremap ]g <Cmd>lua require('vscode').action('editor.action.marker.next')<CR>
    nnoremap [g <Cmd>lua require('vscode').action('editor.action.marker.prev')<CR>
    nnoremap gd <Cmd>lua require('vscode').action('editor.action.revealDefinition')<CR>
    nnoremap gu <Cmd>lua require('vscode').action('editor.action.goToReferences')<CR>
    nnoremap zz <Cmd>lua require('vscode').action('revealLine', { args = { at = "center", lineNumber = vim.api.nvim_win_get_cursor(0)[1] }})<CR>
    nnoremap zt <Cmd>lua require('vscode').action('revealLine', { args = { at = "top", lineNumber = vim.api.nvim_win_get_cursor(0)[1] }})<CR>
    nnoremap zb <Cmd>lua require('vscode').action('revealLine', { args = { at = "bottom", lineNumber = vim.api.nvim_win_get_cursor(0)[1] }})<CR>
    nnoremap <spacer>sdf <Cmd>lua print('ok there buddy')<CR>
    " 👇 this doesn't work
    nnoremap <c-n> <Cmd>lua require('vscode').action('editor.action.addSelectionToNextFindMatch')<CR>
    vnoremap <c-n> <Cmd>lua require('vscode').action('editor.action.addSelectionToNextFindMatch')<CR>
    nnoremap K <Cmd>lua require('vscode').action('editor.action.showHover')<CR>
    " note: shift-k is in keybindings.json
  ]]
  vim.keymap.set('n', '<leader>gi', function()
    vim.cmd.echo('"opening in neovim"')
    require('vscode').action('workbench.action.tasks.runTask', {args = {'open in neovim'}})
  end);
end

-- https://www.reddit.com/r/neovim/comments/1ex4tim/my_top_20_neovim_key_bindings_what_are_yours/
vim.keymap.set("n", "gp", "`[v`]", { desc = "select pasted text" })

vim.api.nvim_create_user_command("CountOccurences", function()
  local search_query = vim.fn.getreg('/')
  if (search_query == '') then
    vim.notify("No search")
    return
  end
  local search_count = vim.fn.searchcount({recompute = true, pattern = search_query, maxcount = 0, timeout=0}).total
  vim.notify("" .. search_count .. " occurences of " .. search_query)
end, {})

vim.api.nvim_create_autocmd('FileType', {
  group = 'init.lua',
  pattern = 'javascripreact,typescriptreact',
  callback = function()
    -- TODO I would like to be able to use this:
    -- > require("nvim-treesitter.ts_utils").update_selection(0, '@function.outer', 'v')
    vim.api.nvim_buf_create_user_command(0, 'ReactSurroundUseCallback', function()
      vim.cmd.normal('ysam)')
      vim.cmd.normal('h')
      vim.api.nvim_paste('useCallback', false, -1)
      vim.cmd.normal('h')
      vim.schedule(function()
        vim.cmd.normal('f(%')
        vim.cmd.normal('h')
        vim.api.nvim_paste(', []', false, -1)
        vim.schedule(function()
          vim.cmd.normal('')
        end)
      end)
    end, {})
  end,
})
