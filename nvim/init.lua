-- vim: ts=2 sw=2
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ Author: Jon Smithers <jon@smithers.dev>                                 │
-- │ URL:    https://github.com/jonsmithers/dotfiles/blob/main/nvim/init.lua │
-- └─────────────────────────────────────────────────────────────────────────┘

vim.opt.breakindent = true
vim.opt.undofile = true

vim.opt.spellfile = {
  vim.env.HOME .. '/.config/nvim/spell/en.utf-8.add',
  -- insert machine-specific spell files below
}

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

local is_kitty = vim.env.TERM == 'xterm-kitty'

vim.opt.foldlevelstart = tonumber(vim.env['NVIM_OPT_FOLDLEVELSTART']) or 99
vim.opt.relativenumber = 'true' == vim.env['NVIM_OPT_RELATIVENUMBER']

vim.opt.title = true
vim.o.titlestring = is_kitty and "" or "nvim"
vim.api.nvim_create_autocmd({'BufEnter', 'TermEnter'}, {
  pattern = '*',
  group = 'init.lua',
  callback = function()
    if (vim.g.vscode) then
      return
    end
    -- local cwd = "  %{fnamemodify(getcwd(), ':t')}  "
    local cwd = is_kitty and "  %{fnamemodify(getcwd(), ':t')}/" or "NVIM  %{fnamemodify(getcwd(), ':t')}/"
    if (vim.o.filetype == 'snacks_picker_input') then
      vim.o.titlestring = cwd..(is_kitty and '' or "search")
    elseif (vim.fn.expand('%') == '') then
      vim.o.titlestring = cwd..(is_kitty and '' or "scratch")
    elseif (vim.o.filetype == 'NvimTree') then
      vim.o.titlestring = cwd..(is_kitty and '' or "tree")
    elseif (vim.o.filetype == 'oil') then
      vim.o.titlestring = cwd..(is_kitty and '' or '')
    elseif (vim.o.filetype == 'fugitive') then
      vim.o.titlestring = cwd..(is_kitty and '' or 'git')
    elseif (string.find(vim.fn.expand('%'), 'FZF')) then
      vim.o.titlestring = cwd..(is_kitty and '' or 'search')
    else
      -- vim.o.titlestring = cwd.."%{expand('%:t')}:%l"
      local icon = require'nvim-web-devicons'.get_icon(vim.fn.expand('%:t:r'), vim.fn.expand('%:t:e'))
      local maybe_space = (icon and ' ' or '')
      vim.o.titlestring = cwd.."%{expand('%:t:r')}"..maybe_space..(is_kitty and icon or '')..(maybe_space)
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
    nnoremap ]c <Cmd>lua require('vscode').action('workbench.action.editor.nextChange')<CR>
    nnoremap [c <Cmd>lua require('vscode').action('workbench.action.editor.previousChange')<CR>
    nnoremap ]d <Cmd>lua require('vscode').action('editor.action.marker.next')<CR>
    nnoremap [d <Cmd>lua require('vscode').action('editor.action.marker.prev')<CR>
    nnoremap ]g <Cmd>lua require('vscode').action('editor.action.marker.next')<CR>
    nnoremap [g <Cmd>lua require('vscode').action('editor.action.marker.prev')<CR>
    nnoremap gd <Cmd>lua require('vscode').action('editor.action.revealDefinition')<CR>
    nnoremap gu <Cmd>lua require('vscode').action('editor.action.goToReferences')<CR>
    nnoremap zz <Cmd>lua require('vscode').action('revealLine', { args = { at = "center", lineNumber = vim.api.nvim_win_get_cursor(0)[1] }})<CR>
    vnoremap zz <Cmd>lua require('vscode').action('revealLine', { args = { at = "center", lineNumber = vim.api.nvim_win_get_cursor(0)[1] }})<CR>
    nnoremap zt <Cmd>lua require('vscode').action('revealLine', { args = { at = "top", lineNumber = vim.api.nvim_win_get_cursor(0)[1] }})<CR>
    vnoremap zt <Cmd>lua require('vscode').action('revealLine', { args = { at = "top", lineNumber = vim.api.nvim_win_get_cursor(0)[1] }})<CR>
    nnoremap zb <Cmd>lua require('vscode').action('revealLine', { args = { at = "bottom", lineNumber = vim.api.nvim_win_get_cursor(0)[1] }})<CR>
    vnoremap zb <Cmd>lua require('vscode').action('revealLine', { args = { at = "bottom", lineNumber = vim.api.nvim_win_get_cursor(0)[1] }})<CR>
    nnoremap <space>gs <Cmd>lua require('vscode').action('workbench.view.scm')<CR>
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
vim.api.nvim_create_user_command('Filepath', function()
  local filepath = vim.fn.expand('%:.')
  vim.fn.setreg('+', filepath)
  print(filepath)
end, {});
vim.api.nvim_create_user_command('FilepathAbsolute', function()
  local filepath = vim.fn.expand('%:p')
  vim.fn.setreg('+', filepath)
  print(filepath)
end, {});

vim.api.nvim_create_autocmd('FileType', {
  group = 'init.lua',
  pattern = 'javascripreact,typescriptreact',
  callback = function()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = 'init.lua',
  pattern = 'markdown',
  callback = function()
    vim.keymap.set('n', '<leader>X', function()
      local line = vim.api.nvim_get_current_line()
      if line:match('%- %[ %]') then
        vim.api.nvim_set_current_line((line:gsub('%- %[ %]', '- [x]', 1)))
      elseif line:match('%- %[x%]') or line:match('%- %[X%]') then
        vim.api.nvim_set_current_line((line:gsub('%- %[[xX]%]', '- [ ]', 1)))
      end
    end, { buffer = true, desc = 'toggle markdown checkbox' })
  end,
})

vim.api.nvim_create_user_command('PadDashes', function()
  local line = vim.api.nvim_get_current_line()
  local width = 80
  local padded = ' ' .. line .. ' '
  local remaining = width - #padded
  if remaining <= 0 then return end
  local left = math.floor(remaining / 2)
  local right = remaining - left
  vim.api.nvim_set_current_line(string.rep('-', left) .. padded .. string.rep('-', right))
end, {})
