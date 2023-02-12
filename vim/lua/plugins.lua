-- ┌────────────────┐
-- │ install packer │
-- └────────────────┘
local packer_install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false
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
    autocmd BufWritePost plugins.lua if (match(expand('%'), '^fugitive:/') == -1) | source <afile> | PackerCompile | endif
  augroup end
]])

local packer = require('packer')
local dev_icons_enabled = os.getenv("VIM_DEVICONS") == "1"

-- ┌─────────┐
-- │ plugins │
-- └─────────┘
packer.startup(function(use)

  use { -- gorbit99/codewindow.nvim
    'gorbit99/codewindow.nvim',
    config = function()
      local codewindow = require('codewindow')
      codewindow.setup({
        exclude_filetypes={'NvimTree','fugitive'}
      })
      codewindow.apply_default_keybinds()
    end,
  }

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
      -- 'rafamadriz/friendly-snippets',
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
            local cursor_col = vim.api.nvim_win_get_cursor(0)[2];
            local char_preceeding_cursor = string.sub(vim.api.nvim_get_current_line(), cursor_col, cursor_col)
            if (char_preceeding_cursor == ' ') then
              fallback()
              -- cmp.close()
              return
            end
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
        nnoremap <leader>sT :AerialToggle float<cr>
        nnoremap [<leader>a :AerialPrev<cr>
        nnoremap ]<leader>a :AerialNext<cr>
      ]])

      local lspconfig = require('lspconfig')
      local aerial = require('aerial')
      aerial.setup({})
      local ON_LSP_ATTACH = function(client, bufnr)
        local function nnoremap_buffer(...) vim.api.nvim_buf_set_keymap(bufnr, 'n', ...) end
        local function command_buffer(...) vim.api.nvim_buf_create_user_command(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        -- Enable completion triggered by <c-x><c-o>
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        local opts = { noremap=true, silent=true }

        -- See `:help vim.lsp.*` for documentation on any of the below functions
        nnoremap_buffer('<space>le', '<cmd>EslintFixAll<CR>', opts)
        nnoremap_buffer(']g',        '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        nnoremap_buffer('[g',        '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
        nnoremap_buffer('gi',        '<cmd>TroubleToggle lsp_implementations<CR>', opts)
        nnoremap_buffer('gu',        '<cmd>TroubleToggle lsp_references<CR>', opts)
        nnoremap_buffer('gd',        '<cmd>TroubleToggle lsp_definitions<CR>', opts)
        nnoremap_buffer('gtd',       '<cmd>TroubleToggle lsp_type_definitions<CR>', opts)
        nnoremap_buffer('K',         '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        nnoremap_buffer('<space>lh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
        nnoremap_buffer('<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        nnoremap_buffer('<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        nnoremap_buffer('<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        nnoremap_buffer('<space>lr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        nnoremap_buffer('<space>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        nnoremap_buffer('<space>e',  '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        command_buffer('LspFormat',  'lua vim.lsp.buf.format()', {})
      end

      ENABLE_LSP_SERVER = function(name, options)
        lspconfig[name].setup(vim.tbl_deep_extend("force", {
          capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
          on_attach = ON_LSP_ATTACH,
          flags = {
            debounce_text_changes = 150,
          },
        }, options or {}))
      end
      ENABLE_FRONTEND_LSPS = function()
        if (vim.fn.filereadable('node_modules/.bin/tsserver') == 1) then
          ENABLE_LSP_SERVER('tsserver')
        end
        if (vim.fn.filereadable('node_modules/.bin/eslint') == 1) then
          ENABLE_LSP_SERVER('eslint')
        end
        ENABLE_LSP_SERVER('html')
        ENABLE_LSP_SERVER('cssls')
        ENABLE_LSP_SERVER('jsonls')
      end

      ENABLE_LSP_SERVER('vimls')
      ENABLE_LSP_SERVER('bashls')
      ENABLE_LSP_SERVER('lua_ls', {
        settings = {
          Lua = {
            diagnostics = {
              runtime = {version='LuaJIT'},
              globals = {'vim'},
              workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
              },
            },
          },
        }
      })
      ENABLE_LSP_SERVER('yamlls')

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
        !npm install --global bash-language-server
        " bashls
        !npm install --global @astrojs/language-server
        " astro
        !brew install lua-language-server
        " sumnekko_lua
        !npm install --global yaml-language-server
        " yamlls
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
      {'nvim-telescope/telescope-fzf-native.nvim', run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
    },
    config = function()
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ["<c-\\>"] = require('telescope.actions.layout').toggle_preview,
              ["<c-j>"] = require('telescope.actions').preview_scrolling_down,
              ["<c-k>"] = require('telescope.actions').preview_scrolling_up,
              ["<esc>"] = require('telescope.actions').close,
            },
            n = {
              ["<c-\\>"] = require('telescope.actions.layout').toggle_preview,
              ["<c-j>"] = require('telescope.actions').preview_scrolling_down,
              ["<c-k>"] = require('telescope.actions').preview_scrolling_up,
            },
          }
        }
      })
      require('telescope').load_extension('aerial')
      require('telescope').load_extension('fzf')
      vim.cmd([[
        com! Planets :lua require('telescope.builtin').planets()<cr>
        com! Symbols :lua require('telescope.builtin').symbols(require('telescope.themes').get_cursor())<cr>
        nnoremap <silent> \tt       :lua require('telescope.builtin').treesitter()<cr>
        " nnoremap <silent> <leader>F       :lua require('telescope.builtin').live_grep({prompt_title = 'FINDY FINDY'})<cr>
        " nnoremap <silent> <leader>or      :lua require('telescope.builtin').oldfiles()<cr>
        " nnoremap <silent> <c-p>           :lua require('telescope.builtin').find_files()<cr>
      ]])
    end
  }

  use { -- rcarriga/nvim-notify
    'rcarriga/nvim-notify',
    -- :Notifications to view notifications
    config = function()
      require('notify').setup({
        -- render='minimal'
      })
      vim.notify = require('notify')
    end
  }

  use { -- rktjmp/lush.nvim
    'rktjmp/lush.nvim'
  }

  use {
    'windwp/nvim-autopairs',
    config = function() require("nvim-autopairs").setup {} end
  }

  use 'wbthomason/packer.nvim'
  if packer_bootstrap then
    packer.sync()
  end
end)
