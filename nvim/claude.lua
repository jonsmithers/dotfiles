-- How to create the terminal split for Claude.
--   "auto"          -- detect the best method from the environment (see below)
--   "nvim"          -- use nvim's built-in terminal in a vertical split
--   "ghostty-macos" -- use Ghostty's AppleScript to create a new terminal split (macOS only)
local TERMINAL_SPLIT = 'auto'

-- Resolve "auto" to a concrete method: prefer Ghostty's AppleScript split when
-- running inside Ghostty on macOS, otherwise fall back to nvim's terminal.
if TERMINAL_SPLIT == 'auto' then
  local is_ghostty = vim.env.TERM == 'xterm-ghostty' or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
  if is_ghostty and vim.fn.has('mac') == 1 then
    TERMINAL_SPLIT = 'ghostty-macos'
  else
    TERMINAL_SPLIT = 'nvim'
  end
end

-- Open the given shell command in a terminal split, using the method resolved
-- above (TERMINAL_SPLIT).
local function open_terminal_split(cmd)
  if TERMINAL_SPLIT == 'ghostty-macos' then
    -- Use Ghostty's AppleScript to open the command in a new terminal split.
    -- Escape the command for embedding inside an AppleScript string literal.
    local applescript_cmd = cmd:gsub('\\', '\\\\'):gsub('"', '\\"')
    local script = string.format([[
tell application "Ghostty"
	set currentTerm to focused terminal of selected tab of front window
	set newTerm to split currentTerm direction right
	input text "%s" & return to newTerm
	-- Re-focus the terminal we split from, since the new split steals focus.
	focus currentTerm
end tell
]], applescript_cmd)
    vim.fn.system({ 'osascript', '-e', script })
  else
    vim.cmd.vsplit()
    vim.cmd.terminal(cmd)
    vim.cmd.startinsert()
  end
end

vim.keymap.set('n', '<leader>ac<leader>', ':Claude ')
-- In visual mode, prefill the range so the selection is passed to :Claude.
vim.keymap.set('x', '<leader>ac<leader>', ":'<,'>Claude ")
vim.api.nvim_create_user_command('Claude', function(opts)
  local str = table.concat(opts.fargs, ' ')
  -- open claude in a terminal split. Insert the current file path into the prompt for claude, followed by whatever has been typed after ":Claude " (see the "str" variable).
  -- When invoked with a visual selection (opts.range > 0), append the selected
  -- line numbers to the file reference so claude focuses on that range.
  local file = vim.fn.expand('%:p')
  local ref = file
  if file ~= '' and opts.range > 0 then
    if opts.line1 == opts.line2 then
      ref = file .. '#L' .. opts.line1
    else
      ref = file .. '#L' .. opts.line1 .. '-' .. opts.line2
    end
  end
  local prompt = ref ~= '' and ('@' .. ref) or ''
  if str ~= '' then
    prompt = prompt ~= '' and (prompt .. '\n' .. str) or str
  end

  local cmd = 'claude --dangerously-skip-permissions'
  if prompt ~= '' then
    cmd = cmd .. ' ' .. vim.fn.shellescape(prompt)
  end

  open_terminal_split(cmd)
end, { nargs = '*', range = true })
