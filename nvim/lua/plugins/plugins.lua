return {

  { 'MTDL9/vim-log-highlighting' },

  { "NStefan002/screenkey.nvim",
    lazy = false,
    opts = {
      win_opts = {
        border='rounded',
        height = 1,
        col = vim.o.columns,
        row = vim.o.lines - vim.o.cmdheight - 1,
      }
    },
    version = "*", -- or branch = "dev", to use the latest commit
  },

  { 'ahmedkhalf/project.nvim',
    config = function()
      require('project_nvim').setup({
        manual_mode = true
      })
    end,
    keys = {
      { '<leader>gp', '<CMD>Telescope projects<cr>', desc = "Go to Project" }
    },
  },

  { 'akinsho/toggleterm.nvim', opts = {}},

  'bronson/vim-visual-star-search',

  { 'Exafunction/windsurf.nvim',
    enabled = false,
    dependencies = { "nvim-lua/plenary.nvim", },
    opts = {
        enable_chat = true,
        enable_cmp_source = false,
        virtual_text = {
          enabled = true,
          filetypes = {
            [""] = false,
            ["snacks_picker_input"] = false,
          },
        },
    },
    config = function(_, opts)
      require('codeium').setup(opts)
    end,
  },

  { 'folke/flash.nvim',
    event = "VeryLazy",
    enabled = true,
    ---@type Flash.Config
    opts = {
      modes = {
        search = {
          enabled = false,
        },
        char = {
          enabled = false,
          highlight = { backdrop = true },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "o" }, function() require("flash").jump() end,                         desc = "Flash" },
      { "S", mode = { "n", "o" }, function() require("flash").jump({search={forward=false}}) end, desc = "Flash" },
      { "s", mode = { "x", },     function() require("flash").treesitter() end,                   desc = "Flash Treesitter" },
      { "r", mode = "o",          function() require("flash").remote() end,                       desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end,            desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },  function() require("flash").toggle() end,                       desc = "Toggle Flash Search" },
    },
  },

  { "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    keys = {
      { '<leader>qs', function() require("persistence").load() end,                desc = 'Load session for directory' },
      { '<leader>qS', function() require("persistence").select() end,              desc = 'Select session to load' },
      { '<leader>ql', function() require("persistence").load({ last = true }) end, desc = 'Load the last session' },
    },
    opts = {
    },
  },

  { "folke/snacks.nvim",
    enabled = not vim.g.vscode,
    priority = 1000,
    lazy = false,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      image = {
        doc = {
          inline = false,
          float = false,
        },
      },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = false },
      picker = {
      },
      words = { enabled = true },
      zen = { },
    },
    keys = {
      {"<leader>oi", mode = "n", function() Snacks.image.hover() end, desc = "Preview image" },
      {"<c-p>", mode = "n", function() Snacks.picker.files() end, desc = "Pick file"},
      {"<leader>or", mode = "n", function() Snacks.picker.recent({
        layout={
          reverse=true,
          preview='main',
        },
      }) end, desc = "Pick recent file"},
      {"<c-k>", mode = "n", function() Snacks.picker.buffers({
        layout={
          reverse=true,
          preview='main',
        },
      }) end, desc = "Pick recent file"},
      {"<leader>Z", mode = "n", function() Snacks.zen.zoom() end },
    },
  },

  { 'folke/todo-comments.nvim',
    opts = {
    },
    init = function()
      -- https://github.com/folke/todo-comments.nvim/issues/264#issuecomment-2254810084
      vim.api.nvim_create_autocmd('BufEnter', {
          desc = 'Enable todo-comments for text',
          group = vim.api.nvim_create_augroup('user.todo.text', { clear = true }),
          callback = function(ev)
              local config = require 'todo-comments.config'

              local comments_only = string.match(ev.file, '%.md$') == nil
                  and string.match(ev.file, '%.txt$') == nil
                  and string.match(ev.file, '%.adoc$') == nil
                  and string.match(ev.file, '%.asciidoc$') == nil
              if (config.options.highlight ~= nil) then
                config.options.highlight.comments_only = comments_only
              end
              if (config.options.keywords ~= nil) then
                config.options.keywords.TODO.icon=''
              end
          end,
      })
    end
  },

  { 'hedyhli/outline.nvim',
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>go", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      -- Your setup opts here
    },
  },

  { 'junegunn/vim-easy-align',
    -- <C-p> | toggle "live" interactive
    -- <C-g> | cycle "ignore groups"
    init = function()
      vim.cmd[[
        :xmap ga <Plug>(EasyAlign)
        :nmap ga <Plug>(EasyAlign)
      ]]
    end,
  },

  { 'junegunn/fzf',
    dependencies = {
      'junegunn/fzf.vim'
    },
    lazy = false,
    init = function()
      vim.g.fzf_command_prefix = 'Fzf'
      vim.g.fzf_vim = {
        grep_multi_line = 2
      }
    end,
    keys = function()
      Live_global_search = function(initial_query)
        -- TODO try to enable history on fzf's rg function
        local history_file = string.format('/var/tmp/%s.ripgrep.fzf-history',  vim.fn.substitute(vim.fn.getcwd(), '/', '%', 'g'))
        vim.fn['fzf#vim#grep2']("rg --column --line-number --no-heading --color=always --smart-case -- ", initial_query, vim.fn['fzf#vim#with_preview'](), 0)
      end

      return {
        { '<leader>ft', ':Telescope filetypes<enter>' },
        { '<Leader>f/', ':FzfHistory/<Enter>' },
        { '<Leader>f:', ':Telescope command_history<Enter>' }, -- (note - you can call histdel("cmd", "regexp") to delete mistaken history items)
        { '<leader>F', function() Live_global_search("") end, desc = 'Search' },
        { '<leader>sw', function() Live_global_search(vim.fn.expand('<cword>')) end, desc = "Search current word" },
        { '<leader>s', function()
          vim.cmd.normal('"ly')
          Live_global_search(vim.fn.getreg('l'))
        end, desc = "Search current word", mode='v' },

        { '<leader>oR', ':FzfHistory!<Enter>', 'Recent files'},
        { '<c-x><c-k>', '<plug>(fzf-complete-word)', mode = 'i' },
        { '<c-x><c-f>', '<plug>(fzf-complete-path)', mode = 'i' },
        { '<c-x><c-l>', '<plug>(fzf-complete-line)', mode = 'i' },
        { '<c-x>F', '<c-x><c-f>', mode = 'i' }, -- remap native keybinding
      }
    end,
    config = function()
      vim.g.fzf_colors = {
          ['fg']      = {'fg', 'Normal'},
          ['bg']      = {'bg', 'Normal'},
          ['hl']      = {'fg', 'Comment'},
          ['fg+']     = {'fg', 'CursorLine', 'CursorColumn', 'Normal'},
          ['bg+']     = {'bg', 'CursorLine', 'CursorColumn'},
          ['hl+']     = {'fg', 'Statement'},
          ['info']    = {'fg', 'PreProc'},
          ['border']  = {'fg', 'Ignore'},
          ['prompt']  = {'fg', 'Conditional'},
          ['pointer'] = {'fg', 'Exception'},
          ['marker']  = {'fg', 'Keyword'},
          ['spinner'] = {'fg', 'Label'},
          ['header']  = {'fg', 'Comment'}
      }

      vim.api.nvim_create_user_command('LiveGlobalSearch', function(input) Live_global_search(input.args) end, {nargs=1});
      vim.cmd[[
        if (!executable('fzf') && !empty(glob("~/.fzf/bin")))
          " Save fzf from downloading a redundant binary (it's common for GUI vims
          " to not see fzf in the PATH)
          let $PATH=$PATH..":"..expand("~/.fzf/bin")
        endif
      ]]
    end
  },

  { 'kevinhwang91/nvim-ufo',
    enabled = os.getenv('NEOVIM_FOLD_COLUMN') == '1',
    dependencies = {
      'kevinhwang91/promise-async',
      { 'luukvbaal/statuscol.nvim',
        config = function()
          local builtin = require("statuscol.builtin")
          require("statuscol").setup({
            relculright = true,
            segments = {
              {text = {builtin.foldfunc}, click = "v:lua.ScFa"},
              {text = {"%s"}, click = "v:lua.ScSa"},
              {text = {builtin.lnumfunc, " "}, click = "v:lua.ScLa"}
            }
          })
        end
      }
    },
    opts = {
      ---@diagnostic disable-next-line: unused-local
      provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
      end,
    },
    init = function()
      vim.opt.fillchars:append { foldclose="›", foldopen="⌄", foldsep=" " }
      vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
      vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
      vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
    end
  },

  { 'kylechui/nvim-surround',
    opts = {
      surrounds = {
        ["m"] = {
          add = function()
            return { { "memo(" }, { ")" } } -- surrounds with memo
          end,
        },
        ["M"] = {
          add = function()
            return { { "useMemo(() => (" }, { "), [])" } } -- surrounds with useMemo and an empty dependency array
          end,
        },
        ["C"] = {
          add = function()
            return { { "useCallback(" }, { ", [])" } } -- surrounds with useCallback and an empty dependency array
          end,
        },
        ["8"] = {
          add = { "**", "**" },
          find = "%*%*.-%*%*",
          delete = "^(%*%*?)().-(%*%*?)()$",
          change = {
            target = "^(%*%*?)().-(%*%*?)()$",
          },
        },
      },
    },
  },

  { 'lewis6991/gitsigns.nvim',
    -- Gitsigns toggle_word_diff
    -- Gitsigns toggle_current_line_blame
    opts = {
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc or ''})
        end
        map('n', '<leader>gha', gs.stage_hunk, "Stage hunk")
        map('n', '<leader>ghu', gs.undo_stage_hunk, "Undo stage hunk")
        map('n', '<leader>ghr', gs.reset_hunk, "Reset hunk")
        map('n', '<leader>ghp', gs.preview_hunk_inline, 'Preview hunk (inline)')
        map('n', '<leader>ghP', gs.preview_hunk, 'Preview hunk (popup)')
        map('n', '<leader>ga', gs.stage_hunk, "Stage hunk")
        map('v', '<leader>ga', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, "Stage hunk")
        map('n', '<leader>gr', gs.reset_hunk, "Reset hunk")
        map('v', '<leader>gr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, "Reset hunk")
        -- TODO alternative to fugutive diff???
        -- map('n', '<leader>GD', function() gs.diffthis('~') end)
        -- map('n', '<leader>GD', gs.diffthis)
        map('n', '<leader>GB', function() gs.blame_line{full=true} end)
        -- map('n', '<leader>GTB', gs.toggle_current_line_blame)
        if (string.sub(vim.fn.expand('%'), 0,string.len('fugitive://')) ~= 'fugitive://') then
          map('n', ']c', function()
            -- if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, 'Go to next change')
          map('n', '[c', function()
            -- if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, 'Go to previous change')
        end
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'inner hunk')
      end
    },
  },

  { 'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
    },
  },

  { 'MagicDuck/grug-far.nvim' },

  { 'mrjones2014/smart-splits.nvim',
    build = './kitty/install-kittens.bash',
    init = function()
      local smart_splits = require('smart-splits')
      vim.keymap.set('n', '<A-h>', smart_splits.resize_left)
      vim.keymap.set('n', '<A-j>', smart_splits.resize_down)
      vim.keymap.set('n', '<A-k>', smart_splits.resize_up)
      vim.keymap.set('n', '<A-l>', smart_splits.resize_right)
      vim.keymap.set('t', '<A-h>', smart_splits.resize_left)
      vim.keymap.set('t', '<A-j>', smart_splits.resize_down)
      vim.keymap.set('t', '<A-k>', smart_splits.resize_up)
      vim.keymap.set('t', '<A-l>', smart_splits.resize_right)
      -- moving between splits
      vim.keymap.set('n', '<c-space><C-h>', smart_splits.move_cursor_left)
      vim.keymap.set('n', '<c-space><C-j>', smart_splits.move_cursor_down)
      vim.keymap.set('n', '<c-space><C-k>', smart_splits.move_cursor_up)
      vim.keymap.set('n', '<c-space><C-l>', smart_splits.move_cursor_right)
      vim.keymap.set('n', '<c-space><C-\\>', smart_splits.move_cursor_previous)
      -- swapping buffers between windows
      vim.keymap.set('n', '<c-space><c-space><c-h>', smart_splits.swap_buf_left)
      vim.keymap.set('n', '<c-space><c-space><c-j>', smart_splits.swap_buf_down)
      vim.keymap.set('n', '<c-space><c-space><c-k>', smart_splits.swap_buf_up)
      vim.keymap.set('n', '<c-space><c-space><c-l>', smart_splits.swap_buf_right)
    end,
  },

  'nanotee/zoxide.vim',

  { 'neovim/nvim-lspconfig',
    enabled = not vim.g.vscode,
    dependencies = {
      'folke/neodev.nvim',
      'yioneko/nvim-vtsls',
    },
    config = function()
      require("lspconfig.configs").vtsls = require("vtsls").lspconfig
      require("neodev").setup({
        override = function(root_dir, library)
          local tail_dir = string.match(root_dir, '[^/]+/?$')
          if (string.find(root_dir, '%.config/nvim') or tail_dir == 'dotfiles') then
            library.enabled = true
            library.plugins = true
          else
            require('fidget').notify('vim lua development (neodev) is not enabled')
          end
        end,
      })

      local lspconfig = require('lspconfig')
      ---@diagnostic disable-next-line: unused-local
      local ON_LSP_ATTACH = function(client, bufnr)
        local function nnoremap_buffer(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, {
            noremap = true,
            silent = true,
            buffer = bufnr,
            desc = desc,
          })
        end
        local function command_buffer(...) vim.api.nvim_buf_create_user_command(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        -- Enable completion triggered by <c-x><c-o>
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        if (vim.tbl_contains({
          'javascript',
          'javascriptreact',
          'typescript',
          'typescriptreact',
        }, vim.bo.filetype)) then
          nnoremap_buffer('<space>le', '<cmd>EslintFixAll<CR>',                                                                                                   'Eslint Fix')
          nnoremap_buffer('<space>oi', '<cmd>VtsExec organize_imports<CR>',                                                                                       'Organize imports')
        end
        nnoremap_buffer(']g',        '<cmd>lua vim.diagnostic.goto_next()<CR>',                                                                                 'Go to next diagnostic')
        nnoremap_buffer('[g',        '<cmd>lua vim.diagnostic.goto_prev()<CR>',                                                                                 'Go to previous diagnostic')
        nnoremap_buffer('gi',        function() Snacks.picker.lsp_implementations() end,                                                                        'Go to implementations')
        nnoremap_buffer('gu',        '<cmd>Trouble lsp_references<CR>',                                                                                         'Go to usages')
        nnoremap_buffer('gd',        '<cmd>Trouble lsp_definitions<CR>',                                                                                         'Go to definitions')
        nnoremap_buffer('<space>gtd','<cmd>Trouble lsp_type_definitions<CR>',                                                                                   'Go to type definitions')
        -- nnoremap_buffer('K',         '<cmd>lua vim.lsp.buf.hover()<CR>',                                                                                        'Hover')
        nnoremap_buffer('<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',                                                                         'Add workspace folder')
        nnoremap_buffer('<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',                                                                      'Remove workspace folder')
        nnoremap_buffer('<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',                                                   'List workspace folders')
        nnoremap_buffer('<space>lr', '<cmd>lua vim.lsp.buf.rename()<CR>',                                                                                       'Lsp rename')
        nnoremap_buffer('<space>la', '<cmd>lua vim.lsp.buf.code_action()<CR>',                                                                                  'Lsp Action')
        nnoremap_buffer('<space>e',  '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',                                                                 'Lsp Show Line Diagnostic')
        command_buffer('LspFormat',  'lua vim.lsp.buf.format()',                                                                                                {})
        vim.keymap.set('n', '<space>lR', function()
          return ":IncRename "..vim.fn.expand('<cword>')
        end, {
          noremap = true,
          silent = true,
          buffer = bufnr,
          desc = "Lsp rename with preview",
          expr = true,
        })
      end

      ENABLE_LSP_SERVER = function(name, options, on_attach)
        vim.lsp.enable(name);
        vim.lsp.config(name, vim.tbl_deep_extend("force", {
          on_attach = function(client, bufnr)
            ON_LSP_ATTACH(client, bufnr)
          end,
        }, options or {}));
      end
      ENABLE_FRONTEND_LSPS = function()
        ENABLE_LSP_SERVER('vtsls')
        if (vim.fn.filereadable('node_modules/.bin/eslint') == 1) then
          -- TODO migrate from legacy setup
          lspconfig['eslint'].setup({
            on_attach = function(client, bufnr)
              ON_LSP_ATTACH(client, bufnr)
            end,
          })
        end
        ENABLE_LSP_SERVER('html')
        ENABLE_LSP_SERVER('cssls')
        ENABLE_LSP_SERVER('jsonls')
      end

      if (is_deno_dir) then
        ENABLE_LSP_SERVER('denols')
      else
        ENABLE_FRONTEND_LSPS()
      end
      ENABLE_LSP_SERVER('vimls')
      ENABLE_LSP_SERVER('gopls')
      ENABLE_LSP_SERVER('bashls')
      ENABLE_LSP_SERVER('rust_analyzer')
      ENABLE_LSP_SERVER('lua_ls', {
        settings = {
          Lua = {
            diagnostics = {
              runtime = { version='LuaJIT' },
              globals = {
                'vim',
                'hs', -- hammerspoon
                'spoon', -- hammerspoon
              },
              workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
              },
            },
          },
        }
      })
      ENABLE_LSP_SERVER('yamlls')
    end,
    build = function()
      vim.cmd.tabnew()
      vim.cmd.TransientShell('npm install --global vim-language-server')
      vim.cmd.TransientShell('npm install --global @vtsls/language-server')
        -- vimls
      vim.cmd.TransientShell('npm install --global vscode-langservers-extracted')
        -- html, eslint, jsonls, cssls
      vim.cmd.TransientShell('npm install --global bash-language-server')
        -- bashls
      vim.cmd.TransientShell('brew install lua-language-server')
        -- sumnekko_lua
      vim.cmd.TransientShell('npm install --global yaml-language-server')
        -- yamlls
      vim.cmd.TransientShell('command -v go && go install golang.org/x/tools/gopls@latest')
        -- gopls
      vim.cmd.tabprevious()
    end,
  },

  { 'norcalli/nvim-colorizer.lua',
    opts = {},
  },

  { 'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/playground',
      'nvim-treesitter/nvim-treesitter-context',
      'nvim-treesitter/nvim-treesitter-refactor',
      'windwp/nvim-ts-autotag',
      'towolf/vim-helm',
    },
    build = function()
      vim.cmd'TSUpdate'
    end,
    config = function()
      require'nvim-treesitter.configs'.setup {
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn", -- set to `false` to disable one of the mappings
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
            smart_rename = false, -- this isn't working??
          },
        },
        -- grr   | smart rename
        -- {A }A | swap with prev/next argument
        -- [a ]a | move to prev/next argument
        -- [m ]m | move to prev/next method
        -- [M ]M | move to prev/next end of method
        -- -- [c ]c | move to prev/next class
        ---- text objects ----
        -- a | argument
        -- m | method
        -- c | class
        autotag = {
          enable = true,
        },
        group_empty=1,
        special_files={},
        sync_install = true,
        auto_install = true,
        modules = {},
        ignore_install = {},
        ensure_installed = {
          'astro',
          'bash',
          'css',
          'graphql',
          'groovy',
          'html',
          'java',
          'javascript', 'tsx', 'typescript', -- not sure if these overlap/conflict
          'json5',
          'json', 'http', -- required for rest-nvim
          'kotlin',
          'lua',
          'markdown',
          'markdown_inline',
          'prisma',
          'vim',
          'vimdoc',
          'yaml',
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
              [']m'] = '@function.outer',
              -- [']c'] = { query = '@class.outer', desc = 'Next class start' },
              [']a'] = '@parameter.inner',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              -- ['[c'] = '@class.outer',
              ['[a'] = '@parameter.inner',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['}A'] = '@parameter.inner',
            },
            swap_previous = {
              ['{A'] = '@parameter.inner'
            }
          },
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['am'] = '@function.outer',
              ['im'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ['ia'] = '@parameter.inner',
              ['aa'] = '@parameter.outer',
            },
            -- You can choose the select mode (default is charwise 'v')
            selection_modes = {
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.outer'] = 'v',
              -- ['@function.outer'] = 'V', -- linewise
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
        nnoremap <Plug>(unimpaired-enable)C :TSContext enable<cr>
        nnoremap <Plug>(unimpaired-disable)C :TSContext disable<cr>
        nnoremap <Plug>(unimpaired-toggle)C :TSContext toggle<cr>
      ]])
      vim.cmd([[
        autocmd BufRead,BufEnter *.astro set filetype=astro
      ]])
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('nvim_init_treesitter', {}),
        pattern = 'lua,typescriptreact',
        callback = function()
          vim.wo.foldmethod='expr'
          vim.wo.foldexpr='nvim_treesitter#foldexpr()'
          -- vim.o.foldmethod='expr'
          -- vim.o.foldexpr='nvim_treesitter#foldexpr()'
          -- set foldmethod=expr
          -- set foldexpr=nvim_treesitter#foldexpr()
        end,
      })
      -- this doesnt work 🙍‍♂️ 
      local parser_configs = require('nvim-treesitter.parsers').get_parser_configs()
      vim.treesitter.language.register('json5', 'json')
    end
  },

  'mg979/vim-visual-multi',

  { 'numToStr/Comment.nvim',
    -- __NORMAL_______________________
    -- gcc | toggle comment
    -- gbc | toggle block comment
    -- gcA | add comment end of line
    -- gco | add comment next line
    -- gcO | add comment previous line
    -- __VISAUL_______________________
    -- gc  | toggle comment
    -- gb  | toggle block comment
    config = true,
  },

  { 'nvim-pack/nvim-spectre',
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = 'Spectre',
    build = function()
      vim.cmd[[
        !brew install gnu-sed
      ]]
    end
  },

  { 'prettier/vim-prettier',
    build = {
      'yarn install',
    },
    ft = {
      'javascript', 'typescript', 'css',
      'javascriptreact', 'typescriptreact',
      'less', 'scss', 'json', 'graphql',
      'markdown', 'vue', 'svelte', 'yaml',
      'html', 'prisma', 'astro'
    },
    config = function()
      vim.cmd[[
        nnoremap <space>lp <cmd>Prettier<CR>
      ]]
    end
  },

  { 'rbong/vim-flog',
    cmd = { 'Flog' },
    init = function()
      vim.api.nvim_create_user_command('GVF', 'Flog -path=%', {});
      vim.api.nvim_create_user_command('GV', 'Flog', {});
      vim.api.nvim_create_user_command('GVFat', 'Flog -format=[%h]\\ {%Cblue%an}\\ %s%n%b', {});
    end
  },

  { 'rgroli/other.nvim',
    config = function()
      require('other-nvim').setup({
        mappings = {
          {
            pattern = "(.*)/src/main/java/(.*).java$",
            target = "%1/src/test/java/%2Test.java",
            context = "test"
          },
          {
            pattern = "(.*)/src/test/java/(.*)Test.java$",
            target = "%1/src/main/java/%2.java",
            context = "source"
          },
          {
            pattern = "(.*)/([a-zA-Z0-9]*).ts$", -- don't include `"."spec`
            target = "%1/__tests__/%2.spec.ts",
            context = "test"
          },
          {
            pattern = "(.*)/__tests__/(.*).spec.ts$",
            target = "%1/%2.ts",
            context = "source"
          },
          {
            pattern = "(.*)/([a-zA-Z0-9]*).tsx$", -- don't include `"."spec`
            target = "%1/__tests__/%2.spec.tsx",
            context = "test"
          },
          {
            pattern = "(.*)/__tests__/(.*).spec.tsx$",
            target = "%1/%2.tsx",
            context = "source"
          }
        },
      })
    end,
  },

  'rktjmp/lush.nvim',

  { 'Saghen/blink.cmp',
    dependencies = {
      'moyiz/blink-emoji.nvim',
      'Exafunction/windsurf.nvim',
    },
    enabled = not vim.g.vscode,
    version = '*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- See the full "keymap" documentation for information on defining your own keymap.
      keymap = {
        preset = 'default',
        ['<Tab>'] = { 'accept', 'fallback' },
        ['<c-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<c-u>'] = { 'scroll_documentation_up', 'fallback' },
      },
      enabled = function()
        if (vim.tbl_contains({
          '',
          'snacks_picker_input',
        }, vim.bo.filetype)) then
          return false
        end
        return not (vim.b['blink-completion-disabled'] or false)
      end,

      sources = {
        default = vim.list_extend(
          { 'lsp', 'buffer', 'snippets', 'path', 'codeium' }, -- default list
          { 'emoji' }
        ),
        providers = {
          codeium = {
            name = 'Codeium',
            module = 'codeium.blink',
            async = true,
          },
          emoji = {
            module = "blink-emoji",
            name = "Emoji",
            score_offset = 15,
            opts = { insert = true },
            should_show_items = function()
              return true
            end,
          }
        },
      },

      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- Will be removed in a future release
        use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },

      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        },
        menu = {
          draw = {
            -- treesitter = { 'lsp' }
          },
        },
      },

      -- -- Default list of enabled providers defined so that you can extend it
      -- -- elsewhere in your config, without redefining it, due to `opts_extend`
      -- sources = {
      --   default = { 'lsp', 'path', 'snippets', 'buffer' },
      -- },
    },
    opts_extend = { "sources.default" },
    -- dependencies = 'rafamadriz/friendly-snippets',
    init = function()
      function EnableCompletion()
        vim.b['blink-completion-disabled'] = false
        require('fidget').notify('completion enabled')
        vim.b.completion_enabled = true;
      end
      function DisableCompletion()
        vim.b['blink-completion-disabled'] = true
        require('fidget').notify('completion disabled')
        vim.b.completion_enabled = false;
      end
      function ToggleCompletion()
        vim.b['blink-completion-disabled'] = not (vim.b['blink-completion-disabled'] or false)
      end
      vim.cmd([[
        nnoremap <Plug>(unimpaired-disable)<Tab> :lua DisableCompletion()<cr>
        nnoremap <Plug>(unimpaired-enable)<Tab> :lua EnableCompletion()<cr>
        nnoremap <Plug>(unimpaired-toggle)<Tab> :lua ToggleCompletion()<cr>
      ]])
    end,
  },

  { 'sindrets/diffview.nvim',
    opts = {
      keymaps = {
        file_panel = {
          {
            "n", "cc",
            "<Cmd>Git commit <bar> wincmd J<CR>",
            { desc = "Commit staged changes" },
          },
          {
            "n", "ca",
            "<Cmd>Git commit --amend <bar> wincmd J<CR>",
            { desc = "Amend the last commit" },
          },
          {
            "n", "c<space>",
            ":Git commit -m ''",
            { desc = "Populate command line with \":Git commit \"" },
          },
        },
      }
    },
    init = function()
      vim.opt.fillchars:append { diff = "╱" }
      vim.keymap.set('n', '<leader>dv', ':DiffviewFileHistory %<cr>')
      vim.keymap.set('v', '<leader>dv', ':DiffviewFileHistory<cr>')
    end,
  },

  { 'smjonas/inc-rename.nvim',
    config = function()
      require('inc_rename').setup({
          input_buffer_type = "dressing",
      })
    end,
  },

  { 'stevearc/dressing.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    opts = function()
      return {
        input = {
          -- Set to false to disable the vim.ui.input implementation
          enabled = true,

          -- Default prompt string
          default_prompt = 'Input:',

          -- Can be 'left', 'right', or 'center'
          prompt_align = 'left',

          -- When true, <Esc> will close the modal
          insert_only = true,

          -- When true, input will start in insert mode.
          start_in_insert = true,

          -- These are passed to nvim_open_win
          border = 'rounded',
          -- 'editor' and 'win' will default to being centered
          relative = 'cursor',

          -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
          prefer_width = 40,
          width = nil,
          -- min_width and max_width can be a list of mixed types.
          -- min_width = {20, 0.2} means "the greater of 20 columns or 20% of total"
          max_width = { 140, 0.9 },
          min_width = { 20, 0.2 },

          buf_options = {},
          win_options = {
            -- Window transparency (0-100)
            winblend = 10,
            -- Disable line wrapping
            wrap = false,
          },

          -- Set to `false` to disable
          mappings = {
            n = {
              ['<Esc>'] = 'Close',
              ['<CR>'] = 'Confirm',
            },
            i = {
              ['<C-c>'] = 'Close',
              ['<CR>'] = 'Confirm',
              ['<Up>'] = 'HistoryPrev',
              ['<Down>'] = 'HistoryNext',
            },
          },

          override = function(conf)
            -- This is the config that will be passed to nvim_open_win.
            -- Change values here to customize the layout
            return conf
          end,

          -- see :help dressing_get_config
          get_config = nil,
        },
        select = {
          -- Set to false to disable the vim.ui.select implementation
          enabled = true,

          -- Priority list of preferred vim.select implementations
          backend = { 'telescope', 'fzf_lua', 'fzf', 'builtin', 'nui' },

          -- Trim trailing `:` from prompt
          trim_prompt = true,

          -- Options for telescope selector
          -- These are passed into the telescope picker directly. Can be used like:
          -- telescope = require('telescope.themes').get_ivy({...})
          -- telescope = require('telescope.themes').get_cursor({}),

          -- Options for fzf selector
          fzf = {
            window = {
              width = 0.5,
              height = 0.4,
            },
          },

          -- Options for fzf_lua selector
          fzf_lua = {
            winopts = {
              width = 0.5,
              height = 0.4,
            },
          },

          -- Options for nui Menu
          nui = {
            position = '50%',
            size = nil,
            relative = 'editor',
            border = {
              style = 'rounded',
            },
            buf_options = {
              swapfile = false,
              filetype = 'DressingSelect',
            },
            win_options = {
              winblend = 10,
            },
            max_width = 80,
            max_height = 40,
            min_width = 40,
            min_height = 10,
          },

          -- Options for built-in selector
          builtin = {
            -- These are passed to nvim_open_win
            border = 'rounded',
            -- 'editor' and 'win' will default to being centered
            relative = 'editor',

            buf_options = {},
            win_options = {
              -- Window transparency (0-100)
              winblend = 10,
            },

            -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- the min_ and max_ options can be a list of mixed types.
            -- max_width = {140, 0.8} means 'the lesser of 140 columns or 80% of total'
            width = nil,
            max_width = { 140, 0.8 },
            min_width = { 40, 0.2 },
            height = nil,
            max_height = 0.9,
            min_height = { 10, 0.2 },

            -- Set to `false` to disable
            mappings = {
              ['<Esc>'] = 'Close',
              ['<C-c>'] = 'Close',
              ['<CR>'] = 'Confirm',
            },

            override = function(conf)
              -- This is the config that will be passed to nvim_open_win.
              -- Change values here to customize the layout
              return conf
            end,
          },

          -- Used to override format_item. See :help dressing-format
          format_item_override = {},

          -- see :help dressing_get_config
          get_config = nil,
        },
      }
    end
  },

  { 'stevearc/oil.nvim',
    enabled = not vim.g.vscode,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      constrain_cursor = "name",
      skip_confirm_for_simple_edits = true,
      keymaps = (function()

        local default_keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-s>"] = "actions.select_vsplit",
          ["<C-h>"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          -- ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          ["g\\"] = "actions.toggle_trash",
        }

        local show_file_details = nil
        local result = vim.tbl_extend('force', default_keymaps, {
          -- ["<C-v>"] = "actions.select_vsplit",
          ["<C-x>"] = "actions.select_split",
          ["gp"] = "actions.preview",
          ["gd"] = {
            desc = "Toggle file detail view",
            callback = function()
              show_file_details = not show_file_details

              if show_file_details then
                require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
              else
                require("oil").set_columns({ "icon" })
              end
            end,
          },
        })
        result["<C-p>"] = nil
        return result
      end)(),
      use_default_keymaps = false,
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'oil',
        group = 'init.lua',
        callback = function()
          vim.wo.relativenumber = true
          -- TODO make this use current oil directory
          vim.keymap.set("n", "<leader>gT", function() Run_command_in_kitty_window(nil, { return_focus = false}) end, {buffer=true})
        end
      })
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
      vim.keymap.set("n", "<leader>ll", "<CMD>rightbelow vnew % | Oil<CR>", { desc = "Open Oil right" })
      vim.keymap.set("n", "<leader>jj", "<CMD>rightbelow new %  | Oil<CR>", { desc = "Open Oil below" })
      vim.keymap.set("n", "<leader>kk", "<CMD>leftabove new %   | Oil<CR>", { desc = "Open Oil above" })
      vim.keymap.set("n", "<leader>hh", "<CMD>leftabove vnew %  | Oil<CR>", { desc = "Open Oil left" })
    end
  },

  'tpope/vim-abolish',

  'tpope/vim-eunuch',

  'tpope/vim-endwise',

  { 'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-rhubarb',
      'shumphrey/fugitive-gitlab.vim',
      'lewis6991/gitsigns.nvim',
    },
    config = function()

      -- Auto-update Fugitive
      local maybe_update_fugitive = function()
        if vim.fn.exists("*FugitiveDidChange") then
          vim.fn.FugitiveDidChange()
        end
      end
      vim.api.nvim_create_autocmd({
        'BufWritePost',
        'TermClose',
      }, {
        callback = maybe_update_fugitive
      })
      vim.api.nvim_create_autocmd('User', {
        pattern = 'GitSignsChanged',
        callback = maybe_update_fugitive
      })

      -- https://github.com/tpope/vim-fugitive/issues/2205
      vim.cmd([[ command! -nargs=1 Browse silent exec '!open "<args>"' ]])
      vim.cmd[[
        nnoremap <Leader>gb :Git blame -w<cr>
        " ~        reblame at hovered commit
        " A        resize to author column
        " D        resize to date column
        " p        preview commit
        " o        open commit in split
        " O        open commit in tab
        nnoremap <leader>gs :0Git<cr>:normal gU<cr>
        " ri  - Rebase Interactive
        " rw  - Rebase reWord
        " rm  - Rebase Modify
        " rd  - Rebase Drop
        " r<Space> - :Git rebase
        " c?  - help
        " cF  - Commit Fixup (rebase immediately)
        " cS  - Commit Squash (rebase immediately)
        " cc  - Commit Create
        " cvc - Commit Verbose Create
        " ca  - Commit Amend
        " cva - Command Verbose Amend
        " cw  - Commit reWord
        " c<Space> - :Git commit
        " http://vimcasts.org/episodes/fugitive-vim-working-with-the-git-index/
        " c-n, c-p jumps to files
        " -        stages/unstages
        nnoremap <leader>gd :Gvdiffsplit<cr>
        "          (left is index (staged), right is working)
        "          dp      diffput
        "          do      diffget (think "obtain")
        "          :w      write to index/working copy
        "          [c,]c   jump to prev/next change
        "          c-w c-o nice way to exit
        "          c-w c-w goes between columns
        augroup vimrc_fugitive
          au!
          autocmd FileType fugitive setlocal relativenumber
          " stash staged files
          autocmd FileType fugitive nmap <buffer> cZ cz<space>push --staged --message ""<left>
          autocmd FileType fugitive nmap <buffer> g<space> :TransientShell git 
          autocmd FileType fugitive nmap <buffer> c<space> :TransientShell git commit -m ""<left>
          autocmd FileType fugitive nmap <buffer> ce :TransientShell git commit --amend --no-edit<cr>
        augroup END
        com! Gstashes :Gclog -g stash
        vnoremap <silent> <leader>gl :GBrowse!<cr><cr>:lua require('fidget').notify("📋COPIED <c-r>+")<cr>
        nnoremap <silent> <leader>gl :GBrowse!<cr><cr>:lua require('fidget').notify("📋COPIED <c-r>+")<cr>
      ]]
    end
  },

  'tpope/vim-projectionist',

  'tpope/vim-repeat',

  'tpope/vim-rsi',

  { 'tpope/vim-unimpaired',
    init = function()
      vim.cmd[[
        nnoremap <Plug>(unimpaired-disable)a :lua require('fidget').notify('auto-format off')<cr>:set fo-=a<cr>
        nnoremap <Plug>(unimpaired-enable)a :lua require('fidget').notify('auto-format on')<cr>:set fo+=a<cr>
      ]]
    end
  },

  'tpope/vim-sleuth',

  { 'Wansmer/treesj',
    lazy = true,
    cmd = { 'TSJSplit', 'TSJJoin' },
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = {
      use_default_keymaps = false,
      max_join_length = 9000,
    },
    init = function()
      vim.cmd[[
        nmap gS :TSJSplit<cr>
        nmap gJ :TSJJoin<cr>
      ]]
    end
  },
}
