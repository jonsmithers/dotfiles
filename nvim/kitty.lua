vim.api.nvim_create_augroup('kitty.lua', {})
-- ┌────────────────────────────┐
-- │ Kitty Terminal Integration │
-- └────────────────────────────┘
-- other setup:
-- - kitty config:
-- - - remote_control_password "<password>"
-- - - listen_on unix:/tmp/<something>
-- - environment
-- - - export KITTY_RC_PASSWORD='<password>'
local kitty = {
  ---@return number?
  get_current_window_id = function()
    -- return tonumber(io.popen("kitty @ ls --match recent:0 | jq '.[].tabs.[].windows.[].id'"):read('*a'))
    return vim.json.decode(io.popen("kitty @ ls --match recent:0"):read('*a'))[1].tabs[1].windows[1].id
  end,
  ---@param id number
  ---@return boolean
  window_exists = function(id)
    return 0 == os.execute("kitty @ ls --match id:"..id.." &> /dev/null")
  end,
  focus_window_recent = function()
    vim.fn.system({'kitty', '@', 'focus-window', '--match', 'recent:1'})
  end,
  ---@param id number
  ---@param text string
  send_text = function(id, text)
    vim.fn.system({'kitty', '@', 'send-text', '--match', 'id:'..id, text})
  end,
  ---@deprecated
  ---@comment THIS DOES NOT WORK
  ---@comment tall:bias=90;full_size=1;mirrored=false
  ---@param layout string
  goto_layout = function(layout)
    vim.fn.sytem({'kitty', '@', 'set-enabled-layouts', layout})
    vim.fn.system({'kitty', '@', 'goto-layout', layout})
  end
}
local window_id_of_persistent_shell = nil
function Create_or_focus_persistent_window()
  if (window_id_of_persistent_shell == nil or not kitty.window_exists(window_id_of_persistent_shell)) then
    -- if (last_terminal == nil or 0 ~= os.execute("kitty @ ls | jq '.[].tabs.[].windows.[].title' | grep --quiet 🏃")) then
    vim.fn.system({'kitty', '@', 'launch', '--cwd', vim.fn.getcwd(), '--location', 'hsplit', '--title', '🏃'})
    window_id_of_persistent_shell = kitty.get_current_window_id()
  else
    vim.fn.system({'kitty', '@', 'focus-window', '--match', 'id:'..window_id_of_persistent_shell})
  end
  return window_id_of_persistent_shell
end
function Run_command_in_kitty_window(str, opts)
  opts = vim.tbl_extend('force', {
    return_focus = true,
    transient_shell = false,
  }, opts or {})

  local function create_or_focus_window()
    if (opts.transient_shell) then
      vim.fn.system({'kitty', '@', 'launch', '--cwd', vim.fn.getcwd(), '--location', 'hsplit', '--title', '🏃'})
      return kitty.get_current_window_id()
    else
      return Create_or_focus_persistent_window();
    end
  end

  local window_id = create_or_focus_window()

  if (str ~= nil) then
    if (opts.transient_shell) then
      str = str .. '; post_hook exit_on_success'
    end
    kitty.send_text(window_id, str..'\n')
  end
  if (opts.return_focus) then
    kitty.focus_window_recent()
  end
end
vim.keymap.set('n', '<leader>.t', ':TransientShell ')
vim.keymap.set('n', '<leader>.T', ':TransientShell! ')
vim.keymap.set('n', '<leader>.q', function() Run_command_in_kitty_window('exit') end)
vim.keymap.set('n', '<leader>.>', function() Run_command_in_kitty_window(nil, { return_focus = false}) end)
vim.keymap.set('n', '<leader>gt', function() Run_command_in_kitty_window(nil, { return_focus = false}) end)
vim.keymap.set('n', '<leader>.<leader>', ':PersistentShell ')
vim.api.nvim_create_user_command('TransientShell', function(opts)
  local str = table.concat(opts.fargs, ' ')
  str = str .. ' && exit'
  Run_command_in_kitty_window(str, {
    return_focus = not opts.bang,
    transient_shell = true,
  })
end, { nargs = '*', bang = true})
vim.api.nvim_create_user_command('PersistentShell', function(opts)
  local str = table.concat(opts.fargs, ' ')
  Run_command_in_kitty_window(str, {
    return_focus = true
  })
end, { nargs = '*' })
vim.api.nvim_create_user_command('K', function(opts)
  local str = table.concat(opts.fargs, ' ')
  local return_focus = not opts.bang
  if (not return_focus) then
    str = str .. '; exit'
  end
  Run_command_in_kitty_window(str, {
    return_focus = return_focus
  })
end, { nargs = '*', bang = true})


-- ┌──────────────┐
-- │ Test runners │
-- └──────────────┘
local last_command = ':'
vim.keymap.set('n', '<leader>rr', function() Run_command_in_kitty_window(last_command .. '; post_hook_1 ' .. Create_or_focus_persistent_window(), { transient_shell = false }) end)
vim.keymap.set('n', '<leader>!!', function() Run_command_in_kitty_window('!!; post_hook_1 ' .. Create_or_focus_persistent_window() .. '\n', { transient_shell = false }) end)

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = {'*.java'},
  group = 'kitty.lua',
  callback = function()
    vim.api.nvim_buf_create_user_command(0, 'TestFile', function()
      vim.cmd.update()
      last_command = string.format('gw test --offline --tests %s', vim.fn.expand('%:t:r'))
      Run_command_in_kitty_window(last_command, { transient_shell = false })
    end, { nargs = 0})
    vim.api.nvim_buf_create_user_command(0, 'TestOne', function()
      vim.cmd.update()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      vim.fn.search('@\\(Parameterized\\)\\?Test', 'b')
      vim.fn.search('void ')
      vim.cmd.normal('W')
      local test_name=vim.fn.expand('<cword>')
      last_command = string.format('gw test --offline --tests %s.%s', vim.fn.expand('%:t:r'), test_name)
      Run_command_in_kitty_window(last_command, { transient_shell = false })
      vim.api.nvim_win_set_cursor(0, cursor_pos)
    end, { nargs = 0})
    vim.keymap.set('n', '<leader>rt', ':TestOne<cr>', { buffer = 0 })
    vim.keymap.set('n', '<leader>rf', ':TestFile<cr>', { buffer = 0 })
  end
})

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = {'*.tsx', '*.ts'},
  group = 'kitty.lua',
  callback = function()
    vim.api.nvim_buf_create_user_command(0, 'TestFile', function()
      vim.cmd.update()
      last_command = (vim.env.NVIM_YARN_TEST_PREFIX or 'yarn exec jest --coverage=false') .. string.format(' "%s"', vim.fn.expand('%:t:r'))
      Run_command_in_kitty_window(last_command, { transient_shell = false })
    end, { nargs = 0})
    vim.api.nvim_buf_create_user_command(0, 'TestOne', function()
      vim.cmd.update()
      local cursor_pos = vim.api.nvim_win_get_cursor(0);
      vim.fn.search(' \\(it\\|test\\|describe\\)(', 'b')
      vim.cmd.normal('l')
      vim.cmd.normal("yi'")
      local test_name=vim.fn.getreg('0')
      last_command = (vim.env.NVIM_YARN_TEST_PREFIX or 'yarn exec jest --coverage=false') .. string.format(' "%s" -t "%s"', vim.fn.expand('%:t:r'), test_name)
      Run_command_in_kitty_window(last_command, { transient_shell = false })
      vim.api.nvim_win_set_cursor(0, cursor_pos);
    end, { nargs = 0})
    vim.keymap.set('n', '<leader>rt', ':TestOne<cr>', { buffer = 0 })
    vim.keymap.set('n', '<leader>rf', ':TestFile<cr>', { buffer = 0 })
  end
})
