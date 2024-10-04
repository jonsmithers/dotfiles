vim.api.nvim_create_augroup('kitty.lua', {})
-- ┌────────────────────────────┐
-- │ Kitty Terminal Integration │
-- └────────────────────────────┘
-- other setup:
-- - kitty config:
-- - - remote_control_password '<password>' *
-- - - listen_on unix:/tmp/<something>
-- - environment
-- - - export KITTY_RC_PASSWORD='<password>'
local kitty = {}
local global_opts = {
  single_term_mode = false,
}
local global_state = {
  window_id_of_persistent_shell = nil,
  last_command = ':',
}
---@return number
function kitty.get_current_window_id()
  -- return tonumber(io.popen("kitty @ ls --match recent:0 | jq '.[].tabs.[].windows.[].id'"):read('*a'))
  return vim.json.decode(io.popen("kitty @ ls --match recent:0"):read('*a'))[1].tabs[1].windows[1].id
end

---@param id number
---@return boolean
function kitty.window_exists(id)
  return 0 == os.execute("kitty @ ls --match id:"..id.." &> /dev/null")
end
function kitty.focus_window_recent()
  vim.fn.system({'kitty', '@', 'focus-window', '--match', 'recent:1'})
end
---@param id number
---@param text string
function kitty.send_text(id, text)
  vim.fn.system({'kitty', '@', 'send-text', '--match', 'id:'..id, text})
end
---@param layout string
function kitty.goto_layout(layout)
  -- vim.fn.sytem({'kitty', '@', 'set-enabled-layouts', layout})
  vim.fn.system({'kitty', '@', 'goto-layout', layout})
end
---@param opts? { ['persistent_shell']?: boolean, }
---@return number window_id
function kitty.get_and_focus_window(opts)
  opts = vim.tbl_extend('force', {}, opts or {})
  if (global_opts.single_term_mode or opts.persistent_shell) then
    if (global_state.window_id_of_persistent_shell == nil or not kitty.window_exists(global_state.window_id_of_persistent_shell)) then
      -- if (last_terminal == nil or 0 ~= os.execute("kitty @ ls | jq '.[].tabs.[].windows.[].title' | grep --quiet 🏃")) then
      vim.fn.system({'kitty', '@', 'launch', '--cwd', vim.fn.getcwd(), '--location', 'hsplit', '--title', '  '})
      global_state.window_id_of_persistent_shell = kitty.get_current_window_id()
    else
      vim.fn.system({'kitty', '@', 'focus-window', '--match', 'id:'..global_state.window_id_of_persistent_shell})
    end
    return global_state.window_id_of_persistent_shell
  else
    vim.fn.system({'kitty', '@', 'launch', '--cwd', vim.fn.getcwd(), '--location', 'hsplit', '--title', '🏃'})
    return kitty.get_current_window_id()
  end
end
---@param str string | nil
---@param opts? { ['return_focus']?: boolean, ['directory']?: string, ['persistent_shell']?: boolean }
function kitty.run_command(str, opts)
  opts = vim.tbl_extend('force', {
    return_focus = true,
    persistent_shell = false,
  }, opts or {})

  local window_id = kitty.get_and_focus_window({ persistent_shell = opts.persistent_shell })

  if (opts.directory ~= nil) then
    kitty.send_text(window_id, " :; cd '" .. opts.directory .. '\'\n')
  end
  if (str ~= nil) then
    if (not opts.persistent_shell and (opts.transient_shell or not global_opts.single_term_mode)) then
      -- str = str .. '; post_hook_0 exit_on_success'
      str = str .. '; post_hook_2 ' .. window_id
    end
    kitty.send_text(window_id, str..'\n')
  end
  if (opts.return_focus) then
    kitty.focus_window_recent()
  end
end

vim.keymap.set('n', '<leader>.t', ':TransientShell ')
vim.keymap.set('n', '<leader>.T', ':TransientShell! ')
vim.keymap.set('n', '<leader>.q', function() kitty.run_command('exit') end)
vim.keymap.set('n', '<leader>.>', function() kitty.run_command(nil, { return_focus = false}) end)
vim.keymap.set('n', '<leader>gt', function()
  local path = nil
  if (vim.bo.filetype == 'oil') then
    path = string.gsub(vim.fn.expand('%'), '^oil://', '')
  end
  kitty.run_command(nil, { return_focus = false, directory = path, persistent_shell = true });
end)
vim.keymap.set('n', '<leader>.<leader>', ':PersistentShell ')
vim.api.nvim_create_user_command('TransientShell', function(opts)
  local str = table.concat(opts.fargs, ' ')
  str = str .. ' && exit'
  kitty.run_command(str, {persistent_shell = false, return_focus = not opts.bang})
end, { nargs = '*', bang = true})
vim.api.nvim_create_user_command('PersistentShell', function(opts)
  local str = table.concat(opts.fargs, ' ')
  kitty.run_command(str, { persistent_shell = true })
end, { nargs = '*' })

-- ┌──────────────┐
-- │ Test runners │
-- └──────────────┘
vim.keymap.set('n', '<leader>rr', function() kitty.run_command(global_state.last_command) end)
vim.keymap.set('n', '<leader>!!', function() kitty.run_command('!!\n', { persistent_shell = true }) end)

if (vim.g.vscode) then

  vim.api.nvim_buf_create_user_command(0, 'TestOne', function()
    require('vscode').action('testing.runAtCursor', {})
  end, { nargs = 0})
  vim.api.nvim_buf_create_user_command(0, 'TestFile', function()
    require('vscode').action('testing.runCurrentFile', {})
  end, { nargs = 0})

  vim.keymap.set('n', '<leader>rt', ':TestOne<cr>')
  vim.keymap.set('n', '<leader>rf', ':TestFile<cr>')

else

  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = {'*.java'},
    group = 'kitty.lua',
    callback = function()
      vim.api.nvim_buf_create_user_command(0, 'TestFile', function()
        vim.cmd.update()
        global_state.last_command = 'clear\n' .. string.format('gw test --offline --tests %s', vim.fn.expand('%:t:r'))
        kitty.goto_layout('fat')
        kitty.run_command(global_state.last_command)
      end, { nargs = 0})
      vim.api.nvim_buf_create_user_command(0, 'TestOne', function()
        vim.cmd.update()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        if (0 == vim.fn.search('@\\(Parameterized\\)\\?Test', 'bW')) then
          require('fidget').notify('No test found', vim.log.levels.ERROR)
          return
        end
        vim.fn.search('void ')
        vim.cmd.normal('W')
        local test_name=vim.fn.expand('<cword>')
        global_state.last_command = 'clear\n' .. string.format('gw test --offline --tests %s.%s', vim.fn.expand('%:t:r'), test_name)
        kitty.goto_layout('fat')
        kitty.run_command(global_state.last_command)
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
        global_state.last_command = 'clear\n' .. (vim.env.NVIM_YARN_TEST_PREFIX or 'yarn exec jest --coverage=false') .. string.format(' "%s"', vim.fn.expand('%:t:r'))
        kitty.goto_layout('fat')
        kitty.run_command(global_state.last_command)
      end, { nargs = 0})
      vim.api.nvim_buf_create_user_command(0, 'TestOne', function()
        vim.cmd.update()
        local cursor_pos = vim.api.nvim_win_get_cursor(0);
        if (0 == vim.fn.search('^\\s*\\(it\\|test\\|describe\\)(', 'bW')) then
          require('fidget').notify('No test found', vim.log.levels.ERROR)
          return
        end
        vim.cmd.normal('l')
        vim.cmd.normal("yi'")
        local test_name=vim.fn.getreg('0')
        global_state.last_command = 'clear\n' .. (vim.env.NVIM_YARN_TEST_PREFIX or 'yarn exec jest --coverage=false') .. string.format(' "%s" -t "%s"', vim.fn.expand('%:t:r'), vim.fn.escape(test_name, '()'))
        kitty.goto_layout('fat')
        kitty.run_command(global_state.last_command)
        vim.api.nvim_win_set_cursor(0, cursor_pos);
      end, { nargs = 0})
      vim.keymap.set('n', '<leader>rt', ':TestOne<cr>', { buffer = 0 })
      vim.keymap.set('n', '<leader>rf', ':TestFile<cr>', { buffer = 0 })
    end
  })

end
