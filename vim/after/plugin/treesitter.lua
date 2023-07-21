require'nvim-treesitter.configs'.setup {
  -- grr   | smart rename
  -- {A }A | swap with prev/next argument
  -- [a ]a | move to prev/next argument
  -- [m ]m | move to prev/next method
  -- [M ]M | move to prev/next end of method
  -- [c ]c | move to prev/next class
  ---- text objects ----
  -- a | argument
  -- m | method
  -- c | class
  autotag = {
    enable = true,
  },
  group_empty=1,
  special_files={},
  ensure_installed = {
    "astro",
    "json", "http", -- required for rest-nvim
    "javascript", "tsx", "typescript", -- not sure if these overlap/conflict
    "java",
    "graphql",
    "html",
    "bash",
    "kotlin",
    "markdown",
    "markdown_inline",
    "lua",
    "prisma",
    "vim",
    "yaml",
  },
  highlight = {
    enable = true,
  },
  playground = {
    enable = true,
  },
  refactor = {
    highlight_definitions = {
      enable = true,
    },
    smart_rename = {
      enable = true,
    },
  },
  textobjects = {
    move = {
      enable = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]c"] = { query = "@class.outer", desc = "Next class start" },
        ["]a"] = "@parameter.inner",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[c"] = "@class.outer",
        ["[a"] = "@parameter.inner",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["}A"] = "@parameter.inner",
      },
      swap_previous = {
        ["{A"] = "@parameter.inner"
      }
    },
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["am"] = "@function.outer",
        ["im"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ia"] = "@parameter.inner",
        ["aa"] = "@parameter.outer",
      },
      -- You can choose the select mode (default is charwise 'v')
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V', -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
    },
  },
}
require'treesitter-context'.setup {
  enable = false, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
    -- For all filetypes
    -- Note that setting an entry here replaces all other patterns for this entry.
    -- By setting the 'default' entry below, you can control which nodes you want to
    -- appear in the context window.
    default = {
      'class',
      'function',
      'method',
      -- 'for', -- These won't appear in the context
      -- 'while',
      -- 'if',
      -- 'switch',
      -- 'case',
    },
    yaml = {
      'block_mapping_pair'
    },
    -- Example for a specific filetype.
    -- If a pattern is missing, *open a PR* so everyone can benefit.
    --   rust = {
    --       'impl_item',
    --   },
  },
  exact_patterns = {
    -- Example for a specific filetype with Lua patterns
    -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
    -- exactly match "impl_item" only)
    -- rust = true,
  },

  -- [!] The options below are exposed but shouldn't require your attention,
  --     you can safely ignore them.

  separator = nil, -- Separator between context and content. Should be a single character string, like '-'.
  mode = 'topline',
}
vim.cmd([[
  nnoremap <Plug>(unimpaired-enable)C :TSContextEnable<cr>
  nnoremap <Plug>(unimpaired-disable)C :TSContextDisable<cr>
  nnoremap <Plug>(unimpaired-toggle)C :TSContextToggle<cr>
]])
vim.cmd([[
  autocmd BufRead,BufEnter *.astro set filetype=astro
]])
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup("nvim_init_treesitter", {}),
  pattern = "lua,typescriptreact",
  callback = function()
    vim.wo.foldmethod='expr'
    vim.wo.foldexpr='nvim_treesitter#foldexpr()'
    -- vim.o.foldmethod='expr'
    -- vim.o.foldexpr='nvim_treesitter#foldexpr()'
    -- set foldmethod=expr
    -- set foldexpr=nvim_treesitter#foldexpr()
  end,
})
