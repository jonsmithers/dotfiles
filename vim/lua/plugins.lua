-- ┌────────────────┐
-- │ install packer │
-- └────────────────┘
local packer_install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_install_path})
  vim.cmd [[packadd packer.nvim]]
end

-- ┌────────────────┐
-- │ reload plugins │
-- └────────────────┘
vim.cmd([[
  augroup reload_lua_plugins
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

local packer = require('packer')
local dev_icons_enabled = os.getenv("VIM_DEVICONS") == "1"

-- ┌─────────┐
-- │ plugins │
-- └─────────┘
packer.startup(function(use)
  use { -- hrsh7th/nvim-cmp
    'hrsh7th/nvim-cmp',
    requires = {
      'onsails/lspkind.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-vsnip',
      'rafamadriz/friendly-snippets',
      'hrsh7th/cmp-emoji',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          end,
        },
        mapping = {
          ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
          ['<C-x><C-o>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
          ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item()),
          ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item()),
          ['<C-e>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ['<C-y>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
            if cmp.visible() then
              local entry = cmp.get_selected_entry()
              if not entry then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
              else
                cmp.confirm()
              end
            else
              fallback()
            end
          end, {"i","s",}),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' },
          { name = 'emoji' },
          { name = 'path' }
        }, {
          { name = 'buffer' },
          { name = 'cmdline' }
        }),
        window = {
          completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
            col_offset = -3,
            side_padding = 0,
          },
        },
        formatting = {

          -- fields = { "abbr", "menu", "kind" },
          -- format = function(entry, vim_item)
          --   return require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
          -- end,

          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            kind.kind = " " .. strings[1] .. " "
            kind.menu = "    (" .. strings[2] .. ")"

            return kind
          end,
        },
      })

      vim.cmd([[
        imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
        smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
        imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
        smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
      ]])
    end,
  }

  use { -- kyazdani42/nvim-tree.lua
    'kyazdani42/nvim-tree.lua',
    -- tree buffer mappings
    --   P     | jump to parent
    --   <tab> | preview
    --   K     | jump to beginning of directory
    --   J     | jump to end of directory
    --   H     | hide dotfiles
    --   E     | expand child nodes
    --   W     | collapse all nodes
    --   <c-v> | open in vertical split
    --   ]c,[c | next git item
    --   ]g,[g | next diagnostic item
    --   .     | prepopulate command with file
    requires = dev_icons_enabled and {
      'kyazdani42/nvim-web-devicons'
    } or {},
    config = function()
      require'nvim-tree'.setup {
        renderer = {
          indent_markers = {
            enable = true,
          },
        },
        hijack_cursor = true,
        -- hijack_directories = {
        --   enable = true,
        -- },
        hijack_netrw = false,
        disable_netrw = false,
        view = {
          adaptive_size = true,
          relativenumber = true,
          mappings = {
            custom_only = true,
            list = {
              -- { key = "<CR>", action = "edit_in_place" }
              -- BEGIN_DEFAULT_MAPPINGS
              { key = { "<CR>", "o", "<2-LeftMouse>" }, action = "edit" },
              { key = "<C-e>",                          action = "edit_in_place" },
              { key = "O",                              action = "edit_no_picker" },
              { key = { "<C-]>", "<2-RightMouse>" },    action = "cd" },
              { key = "<C-v>",                          action = "vsplit" },
              { key = "<C-x>",                          action = "split" },
              { key = "<C-t>",                          action = "tabnew" },
              { key = "<",                              action = "prev_sibling" },
              { key = ">",                              action = "next_sibling" },
              { key = "P",                              action = "parent_node" },
              { key = "<BS>",                           action = "close_node" },
              { key = "<Tab>",                          action = "preview" },
              { key = "K",                              action = "first_sibling" },
              { key = "J",                              action = "last_sibling" },
              { key = "I",                              action = "toggle_git_ignored" },
              { key = "H",                              action = "toggle_dotfiles" },
              { key = "U",                              action = "toggle_custom" },
              { key = "R",                              action = "refresh" },
              { key = "a",                              action = "create" },
              { key = "d",                              action = "remove" },
              { key = "D",                              action = "trash" },
              { key = "r",                              action = "rename" },
              { key = "<C-r>",                          action = "full_rename" },
              { key = "x",                              action = "cut" },
              { key = "c",                              action = "copy" },
              { key = "p",                              action = "paste" },
              { key = "y",                              action = "copy_name" },
              { key = "Y",                              action = "copy_path" },
              { key = "gy",                             action = "copy_absolute_path" },
              -- { key = "[e",                             action = "prev_diag_item" },
              { key = "[c",                             action = "prev_git_item" },
              -- { key = "]e",                             action = "next_diag_item" },
              { key = "]c",                             action = "next_git_item" },
              { key = "-",                              action = "dir_up" },
              { key = "s",                              action = "system_open" },
              { key = "f",                              action = "live_filter" },
              { key = "F",                              action = "clear_live_filter" },
              { key = "q",                              action = "close" },
              { key = "W",                              action = "collapse_all" },
              { key = "E",                              action = "expand_all" },
              { key = "S",                              action = "search_node" },
              { key = ".",                              action = "run_file_command" },
              -- { key = "<C-k>",                          action = "toggle_file_info" },
              { key = "g?",                             action = "toggle_help" },
              -- END_DEFAULT_MAPPINGS

              { key = "[g",                             action = "prev_diag_item" },
              { key = "]g",                             action = "next_diag_item" },
            }
          },
        },
      }
      vim.cmd([[
        :nnoremap <silent> <Leader>tt :NvimTreeToggle<cr>
        :nnoremap <silent> <Leader>tf :NvimTreeFindFile<CR>
        :nnoremap <silent> <Leader>tr :NvimTreeRefresh<CR>

        " :nnoremap <silent> - :call OpenNvimTreeWithVinegarBehavior()<cr>
        fun! NvimTreeToggleAndRemoveVinegar()
          :NvimTreeToggle
          call NvimTreeRemoveVinegarBehavior()
        endfun
        fun! NvimTreeFindFileAndRemoveVinegar()
          :NvimTreeFindFile
          call NvimTreeRemoveVinegarBehavior()
        endfun
        fun! NvimTreeRemoveVinegarBehavior()
          if (&filetype == 'NvimTree')
            nunmap <buffer> <cr>
            nnoremap <buffer> <cr> :lua require'nvim-tree.actions'.on_keypress('enter')<cr>
            wincmd p
          endif
        endfun
        fun! OpenNvimTreeWithVinegarBehavior()
          NvimTreeClose
          if (expand('%') == '')
            let l:window_count = winnr('$')
            if (l:window_count == 1)
              edit .
            else
              " TODO this clobbers existing splits for some reason
              echom 'would clobber layout'
            endif
          else
            lua require"nvim-tree".open_replacing_current_buffer()
          endif
          " file nvim_vinegar
          " ^ lets fzf file picker replace this buffer
          " if (&filetype == 'NvimTree')
          "   nunmap <buffer> <cr>
          "   nnoremap <buffer> <cr> :lua require'nvim-tree.actions'.on_keypress('edit_in_place')<cr>
          " endif
        endfun
      ]])
    end
  }

  use { -- neovim/nvim-lspconfig
    'neovim/nvim-lspconfig',
    requires = {
      'stevearc/aerial.nvim'
    },
    config = function()
      vim.cmd([[
        com! LspDisableCompletion lua require('cmp').setup.buffer { enabled = false }
        com! LspEnableCompletion lua require('cmp').setup.buffer { enabled = true }
        nnoremap [o<c-space> :LspEnableCompletion<cr>
        nnoremap ]o<c-space> :LspDisableCompletion<cr>
        nnoremap <leader>st :AerialToggle!<cr>
      ]])

      local lspconfig = require('lspconfig')
      local aerial = require('aerial')
      aerial.setup({})
      local ON_LSP_ATTACH = function(client, bufnr)
        aerial.on_attach(client, buffer)

        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        -- Enable completion triggered by <c-x><c-o>
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        local opts = { noremap=true, silent=true }

        -- See `:help vim.lsp.*` for documentation on any of the below functions
        buf_set_keymap('n', '<space>le', '<cmd>EslintFixAll<CR>', opts)
        buf_set_keymap('n', ']g', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '[g', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', 'K',         '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', '<space>lh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        -- buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', '<space>lr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', '<space>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
        buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
      end

      enable_lsp_server = function(name)
        lspconfig[name].setup {
          capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
          on_attach = ON_LSP_ATTACH,
          flags = {
            debounce_text_changes = 150,
          }
        }
      end
      enable_frontend_lsps = function()
        if (vim.fn.empty(vim.fn.glob('node_modules/.bin/tsserver'))) then
          enable_lsp_server('tsserver')
        end
        if (vim.fn.empty(vim.fn.glob('node_modules/.bin/eslint'))) then
          enable_lsp_server('eslint')
        end
        enable_lsp_server('html')
        enable_lsp_server('cssls')
        enable_lsp_server('jsonls')
      end

      enable_lsp_server('vimls')

      vim.cmd([[
        call SetupDirectorySpecificConfiguration()
      ]])
    end,
    run = function()
      vim.cmd([[
        echom "manually installing LSP servers"
        !npm install --global typescript-language-server
        " tsserver
        !npm install --global vim-language-server
        " vimls
        !npm install --global vscode-langservers-extracted
        " html, eslint, jsonls, cssls
      ]])
    end,
  }

  use { -- NTBBloodbath/rest.nvim
    'NTBBloodbath/rest.nvim',
    -- Perform REST requests in http files
    requires = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('rest-nvim').setup({
        -- Open request results in a horizontal split
        result_split_horizontal = false,
        -- Keep the http file buffer above|left when split horizontal|vertical
        result_split_in_place = false,
        -- Skip SSL verification, useful for unknown certificates
        skip_ssl_verification = false,
        -- Highlight request on run
        highlight = {
          enabled = true,
          timeout = 150,
        },
        -- Jump to request line on run
        jump_to_request = false,
        env_file = 'http.env',
        yank_dry_run = true,
      })
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup("lua config", {}),
        pattern = "http",
        callback = function()
          vim.api.nvim_buf_set_keymap(0, 'n', '<leader>rr', ':lua require("rest-nvim").run()<cr>', {})
          print('use <leader>rr to run rest method')
        end,
      })
    end
  }

  use { -- nvim-telescope/telescope.nvim
    'nvim-telescope/telescope.nvim',
    -- Telescope Picker mappings
    --   ctrl-c   | close
    --   ctrl-u/d | scroll preview
    --   ctrl-q   | open ALL in quickfix
    --   alt-q    | open SELECTED in quickfix
    --   ctrl-v   | vertical split
    --   ctrl-t   | open in tab
    --   ? view   | mappings
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-symbols.nvim',
    },
    config = function()
      require('telescope').setup({
        defaults = {
          mappings = {
            -- i = { ["<c-t>"] = require("trouble.providers.telescope").open_with_trouble },
            -- n = { ["<c-t>"] = require("trouble.providers.telescope").open_with_trouble },
          }
        }
      })
      vim.cmd([[
        com! Planets :lua require('telescope.builtin').planets()<cr>
        com! Symbols :lua require('telescope.builtin').symbols(require('telescope.themes').get_cursor())<cr>
        nnoremap <silent> <leader>F       :lua require('telescope.builtin').live_grep({prompt_title = 'FINDY FINDY'})<cr>
        nnoremap <silent> <leader>or      :lua require('telescope.builtin').oldfiles()<cr>
        nnoremap <silent> <c-p>           :lua require('telescope.builtin').find_files()<cr>
      ]])
    end
  }

  use { -- nvim-treesitter/nvim-treesitter
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-context',
      'nvim-treesitter/nvim-treesitter-textobjects',
      -- TSContextEnable, TSContextDisable, TSContextToggle
    },
    config = function()
      require'nvim-treesitter.configs'.setup {
        group_empty=1,
        special_files={},
        ensure_installed = {
          "json", "http", -- required for rest-nvim
          "javascript", "tsx", "typescript", -- not sure if these overlap/conflict
          "bash",
          "lua",
          "vim",
          "yaml",
        },
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
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
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
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
        nnoremap [oC :TSContextEnable<cr>
        nnoremap ]oC :TSContextDisable<cr>
        nnoremap yoC :TSContextToggle<cr>
      ]])
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup("nvim_init_treesitter", {}),
        pattern = "lua",
        callback = function()
          vim.wo.foldmethod='expr'
          vim.wo.foldexpr='nvim_treesitter#foldexpr()'
          -- vim.o.foldmethod='expr'
          -- vim.o.foldexpr='nvim_treesitter#foldexpr()'
          -- set foldmethod=expr
          -- set foldexpr=nvim_treesitter#foldexpr()
        end,
      })
    end
  }

  use { -- rcarriga/nvim-notify
    'rcarriga/nvim-notify',
    config = function()
      require('notify').setup({
        render='minimal'
      })
      vim.notify = require('notify')
    end
  }

  use { -- stevearc/dressing.nvim
    'stevearc/dressing.nvim',
    config = function()
      require('dressing').setup({
        input = {
          -- Default prompt string
          default_prompt = "➤ ",

          -- When true, <Esc> will close the modal
          insert_only = true,

          -- These are passed to nvim_open_win
          anchor = "SW",
          relative = "cursor",
          border = "rounded",

          -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
          prefer_width = 40,
          max_width = nil,
          min_width = 20,

          -- Window transparency (0-100)
          winblend = 10,
          -- Change default highlight groups (see :help winhl)
          winhighlight = "",

          -- see :help dressing_get_config
          get_config = nil,
        },
        select = {
          -- Priority list of preferred vim.select implementations
          backend = { "builtin" },

          -- Options for telescope selector
          telescope = {
          },

          -- Options for fzf selector
          fzf = {
            window = {
              width = 0.5,
              height = 0.4,
            },
          },

          -- Options for nui Menu
          nui = {
            position = "50%",
            size = nil,
            relative = "editor",
            border = {
              style = "rounded",
            },
            max_width = 80,
            max_height = 40,
          },

          -- Options for built-in selector
          builtin = {
            -- These are passed to nvim_open_win
            anchor = "NW",
            relative = "cursor",
            border = "rounded",

            -- Window transparency (0-100)
            winblend = 10,
            -- Change default highlight groups (see :help winhl)
            winhighlight = "",

            -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            width = nil,
            max_width = 0.8,
            min_width = 40,
            height = nil,
            max_height = 0.9,
            min_height = 10,
          },

          -- Used to override format_item. See :help dressing-format
          format_item_override = {},

          -- see :help dressing_get_config
          get_config = nil,
        },
      })

    end,
  }

  use 'wbthomason/packer.nvim'
  if packer_bootstrap then
    packer.sync()
  end
end)
