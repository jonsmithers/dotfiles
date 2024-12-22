vim.api.nvim_create_augroup('terminal.lua', {})
local terminal = {}
local global_opts = {
  single_term_mode = false,
}
local global_state = {
  last_command = ':',
}
function terminal.run_command(str, opts)
  local current_win = vim.api.nvim_get_current_win()
  opts = vim.tbl_extend('force', {
    return_focus = true,
    persistent_shell = false,
  }, opts or {})
  local term_id = opts.persistent_shell and 1 or math.random(100000,999999)
  if (opts.directory ~= nil) then
    vim.cmd({cmd = 'TermExec', args = {"cmd=' :; cd '"..opts.directory.."'"}, count=term_id})
  end
  if (str ~= nil) then
    if (not opts.persistent_shell and (opts.transient_shell or not global_opts.single_term_mode)) then
      str = str .. " && exit"
    end
    vim.cmd({cmd = 'TermExec', args = {"cmd='".. str .. "'"}, count=term_id})
  else
    -- TODO this dont work
    vim.cmd({cmd = 'TermExec', args = {"cmd=':'"}, count=term_id})
  end
  if (opts.return_focus) then
    vim.api.nvim_set_current_win(current_win)
  end
end

vim.keymap.set('n', '<leader>.t', ':TransientShell ')
vim.keymap.set('n', '<leader>.T', ':TransientShell! ')
vim.keymap.set('n', '<leader>.q', function() terminal.run_command('exit') end)
vim.keymap.set('n', '<leader>.>', function() terminal.run_command(nil, { return_focus = false}) end)
vim.keymap.set('n', '<leader>gt', function()
  local path = nil
  if (vim.bo.filetype == 'oil') then
    path = string.gsub(vim.fn.expand('%'), '^oil://', '')
  end
  terminal.run_command(nil, { return_focus = false, directory = path, persistent_shell = true });
end)
vim.keymap.set('n', '<leader>.<leader>', ':PersistentShell ')
vim.api.nvim_create_user_command('TransientShell', function(opts)
  local str = table.concat(opts.fargs, ' ')
  terminal.run_command(str, {persistent_shell = false, return_focus = not opts.bang})
  -- vim.cmd({cmd = 'TermExec', args = {"cmd='"..str.." && exit'"}, count=math.random(100000,999999)})
end, { nargs = '*', bang = true})
vim.api.nvim_create_user_command('PersistentShell', function(opts)
  local str = table.concat(opts.fargs, ' ')
  terminal.run_command(str, {persistent_shell = true, return_focus = not opts.bang})
end, { nargs = '*' })

-- ┌──────────────┐
-- │ Test runners │
-- └──────────────┘
vim.keymap.set('n', '<leader>rr', function() terminal.run_command(global_state.last_command) end)
vim.keymap.set('n', '<leader>!!', function() terminal.run_command('!!\n', { persistent_shell = true }) end)

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
    group = 'terminal.lua',
    callback = function()
      vim.api.nvim_buf_create_user_command(0, 'TestFile', function()
        vim.cmd.update()
        global_state.last_command = 'clear\n' .. string.format('gw test --offline --console=rich --tests %s', vim.fn.expand('%:t:r'))
        terminal.run_command(global_state.last_command)
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
        global_state.last_command = 'clear\n' .. string.format('gw test --offline --console=rich --tests \'%s*.%s\'', vim.fn.expand('%:t:r'), test_name)
        terminal.run_command(global_state.last_command)
        vim.api.nvim_win_set_cursor(0, cursor_pos)
      end, { nargs = 0})
      vim.keymap.set('n', '<leader>rt', ':TestOne<cr>', { buffer = 0 })
      vim.keymap.set('n', '<leader>rf', ':TestFile<cr>', { buffer = 0 })
    end
  })

  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = {'*.tsx', '*.ts'},
    group = 'terminal.lua',
    callback = function()
      vim.api.nvim_buf_create_user_command(0, 'TestFile', function()
        vim.cmd.update()
        global_state.last_command = 'clear\n' .. (vim.env.NVIM_YARN_TEST_PREFIX or 'yarn exec jest --coverage=false --colors') .. string.format(' "%s"', vim.fn.expand('%:t:r'))
        terminal.run_command(global_state.last_command)
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
        global_state.last_command = 'clear\n' .. (vim.env.NVIM_YARN_TEST_PREFIX or 'yarn exec jest --coverage=false --colors') .. string.format(' "%s" -t "%s"', vim.fn.expand('%:t:r'), vim.fn.escape(test_name, '()'))
        terminal.run_command(global_state.last_command)
        vim.api.nvim_win_set_cursor(0, cursor_pos);
      end, { nargs = 0})
      vim.keymap.set('n', '<leader>rt', ':TestOne<cr>', { buffer = 0 })
      vim.keymap.set('n', '<leader>rf', ':TestFile<cr>', { buffer = 0 })
    end
  })


  return terminal
end
