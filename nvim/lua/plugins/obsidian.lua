return {
  {
    "obsidian-nvim/obsidian.nvim",
    enabled = true,
    version = "*", -- recommended, use latest release instead of latest commit
    -- ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
        -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
        -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
        -- refer to `:h file-pattern` for more examples
        "BufReadPre /Users/jonsmithers/Dropbox/obsidian/*.md",
        "BufNewFile /Users/jonsmithers/Dropbox/obsidian/*.md",
    },
    init = function()
      vim.opt.conceallevel = 2
    end,
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "personal",
          path = "~/Dropbox/obsidian/",
        },
      },
    },
  }
}
