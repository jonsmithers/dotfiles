-- ┌──────────────────────────┐
-- │ Claude Code Integration  │
-- └──────────────────────────┘
-- Provides a :Claude command (and <leader>ac mapping) that launches the
-- `claude` CLI in a terminal split, prefilled with a reference to the current
-- file (and visual selection, if any) plus an optional prompt:
-- - `:Claude do the thing`   -- launch immediately with the given prompt
-- - `:Claude`                -- open a floating scratch buffer to compose a
--                               multiline prompt, then <CR> to send
-- - `:'<,'>Claude`           -- include the selected line range in the reference
-- The terminal split is created via Ghostty (macOS), kitty, or nvim's built-in
-- terminal, auto-detected from the environment (see TERMINAL_SPLIT_METHOD).

-- How to create the terminal split for Claude.
--   "auto"          -- detect the best method from the environment (see below)
--   "nvim"          -- use nvim's built-in terminal in a vertical split
--   "ghostty-macos" -- use Ghostty's AppleScript to create a new terminal split (macOS only)
--   "kitty"         -- use kitty's remote control to create a new terminal split
local TERMINAL_SPLIT_METHOD = 'auto'

-- Resolve "auto" to a concrete method: prefer Ghostty's AppleScript split when
-- running inside Ghostty on macOS, use kitty's remote control when running
-- inside kitty, otherwise fall back to nvim's terminal.
if TERMINAL_SPLIT_METHOD == 'auto' then
  local is_ghostty = vim.env.TERM == 'xterm-ghostty' or vim.env.GHOSTTY_RESOURCES_DIR ~= nil
  local is_kitty = vim.env.TERM == 'xterm-kitty' or vim.env.KITTY_WINDOW_ID ~= nil
  if is_ghostty and vim.fn.has('mac') == 1 then
    TERMINAL_SPLIT_METHOD = 'ghostty-macos'
  elseif is_kitty then
    TERMINAL_SPLIT_METHOD = 'kitty'
  else
    TERMINAL_SPLIT_METHOD = 'nvim'
  end
end

-- Open the given shell command in a terminal split, using the method resolved
-- above (TERMINAL_SPLIT_METHOD).
local function open_terminal_split(cmd)
  if TERMINAL_SPLIT_METHOD == 'ghostty-macos' then
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
  elseif TERMINAL_SPLIT_METHOD == 'kitty' then
    -- Use kitty's remote control to open a new split running the command.
    -- Launch a shell that runs the command then stays open, so the claude
    -- session (and its scrollback) remains after it exits.
    local nvim_window_id = vim.env.KITTY_WINDOW_ID
    -- Run through the user's interactive login shell so PATH (and thus the
    -- `claude` executable) is resolved, then keep the shell open afterwards.
    local shell = vim.env.SHELL or 'sh'
    vim.fn.system({
      'kitty', '@', 'launch',
      '--cwd', 'current',
      '--location', 'vsplit',
      shell, '-i', '-c', cmd .. '; exec ' .. shell .. ' -i',
    })
    -- Re-focus nvim, since the new split steals focus.
    if nvim_window_id then
      vim.fn.system({ 'kitty', '@', 'focus-window', '--match', 'id:' .. nvim_window_id })
    end
  else
    vim.cmd.vsplit()
    vim.cmd.terminal(cmd)
    vim.cmd.startinsert()
  end
end

-- Build the final prompt (file reference + user text) and launch claude in a
-- terminal split. `ref` is the "@file#Lx-y" reference (may be empty); `str` is
-- the free-form prompt text, which may contain newlines.
local function launch_claude(ref, str)
  local prompt = ref ~= '' and ('@' .. ref) or ''
  if str ~= '' then
    prompt = prompt ~= '' and (prompt .. '\n' .. str) or str
  end

  local cmd = 'claude --dangerously-skip-permissions'
  if prompt ~= '' then
    -- shellescape preserves real newlines inside the single-quoted argument.
    cmd = cmd .. ' ' .. vim.fn.shellescape(prompt)
  end

  open_terminal_split(cmd)
end

-- Open a floating scratch window (via Snacks.win) for composing a true
-- multiline prompt. Press <CR> in normal mode to send it to claude, or q/<Esc>
-- to cancel.
local function open_prompt_buffer(ref)
  -- Seed with the file reference as a comment-y first line for context, but the
  -- reference is added by launch_claude() so the user only types their prompt.
  local seed = {}
  if ref ~= '' then
    seed = { '# ' .. ref .. ' (reference — do not edit)', '', '' }
  end

  local win = require('snacks').win({
    relative = 'editor',
    position = 'float',
    border = 'rounded',
    title = ' Claude prompt ',
    title_pos = 'center',
    width = 0.6,
    height = 0.4,
    text = seed,
    bo = { buftype = 'nofile', bufhidden = 'wipe', swapfile = false, filetype = 'markdown' },
    wo = { wrap = true },
    start_insert = true,
    enter = true,
    keys = {
      q = 'close',
      send = {
        '<CR>',
        function(self)
          local lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)
          -- Drop the reference/instruction line we seeded above.
          if ref ~= '' and lines[1] and lines[1]:match('%(reference') then
            table.remove(lines, 1)
          end
          local str = vim.trim(table.concat(lines, '\n'))
          self:close()
          launch_claude(ref, str)
        end,
        mode = 'n',
      },
    },
  })

  -- Place the cursor below the seeded reference line, then enter insert mode so
  -- the user can start typing their prompt immediately.
  if ref ~= '' then
    vim.api.nvim_win_set_cursor(win.win, { 3, 0 })
  end
  vim.cmd('startinsert')
end

vim.keymap.set('n', '<leader>ac', ':Claude<cr>')
-- In visual mode, prefill the range so the selection is passed to :Claude.
vim.keymap.set('x', '<leader>ac', ":'<,'>Claude<cr>")
vim.api.nvim_create_user_command('Claude', function(opts)
  local str = table.concat(opts.fargs, ' ')
  -- Users can't type literal newlines on the command line, so translate the
  -- escape sequence "\n" into a real newline for quick multiline prompts.
  str = str:gsub('\\n', '\n')
  -- open claude in a terminal split. Insert the current file path into the prompt for claude, followed by whatever has been typed after ":Claude " (see the "str" variable).
  -- When invoked with a visual selection (opts.range > 0), append the selected
  -- line numbers to the file reference so claude focuses on that range.
  local file = vim.fn.expand('%:p')
  -- Save the current file first so claude reads the on-disk contents that match
  -- what's in the buffer (update only writes if the buffer is modified).
  if file ~= '' then
    vim.cmd('silent! update')
  end
  local ref = file
  if file ~= '' and opts.range > 0 then
    if opts.line1 == opts.line2 then
      ref = file .. '#L' .. opts.line1
    else
      ref = file .. '#L' .. opts.line1 .. '-' .. opts.line2
    end
  end

  -- With no prompt text, open a scratch buffer for composing a full multiline
  -- prompt; otherwise launch directly with the (possibly \n-expanded) text.
  if str == '' then
    open_prompt_buffer(ref)
  else
    launch_claude(ref, str)
  end
end, { nargs = '*', range = true })
