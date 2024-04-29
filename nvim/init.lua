-- vim: ts=2 sw=2
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ Author: Jon Smithers <jon@smithers.dev>                                 │
-- │ URL:    https://github.com/jonsmithers/dotfiles/blob/main/nvim/init.lua │
-- └─────────────────────────────────────────────────────────────────────────┘

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' '
vim.cmd.source(vim.env.HOME .. '/.config/nvim/init2.vim')

vim.api.nvim_create_augroup('init.lua', {})
local dev_icons_enabled = os.getenv('VIM_DEVICONS') == '1'

-- ┌─────────┐
-- │ PLUGINS │
-- └─────────┘
require('lazy').setup({

  { 'ahmedkhalf/project.nvim',
    config = function()
      require('project_nvim').setup({
        manual_mode = true
      })
    end
  },

  'bronson/vim-visual-star-search',

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
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n",      "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  { "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    opts = {
      -- add any custom options here
    },
    init = function()
      vim.api.nvim_set_keymap("n", "<leader>ql", [[<cmd>lua require("persistence").load({ last = true })<cr>]], {})
    end
  },

  { 'folke/trouble.nvim',
    dependencies = {
      'tpope/vim-unimpaired',
    },
    config = function()
      vim.cmd[[
        nnoremap ]t :lua require("trouble").next({skip_groups = true, jump = true})<cr>
        nnoremap [t :lua require("trouble").previous({skip_groups = true, jump = true})<cr>
        nnoremap <Plug>(unimpaired-disable)t :TroubleClose<cr>
        nnoremap <Plug>(unimpaired-enable)t :Trouble<cr>
        nnoremap <Plug>(unimpaired-toggle)t :TroubleToggle<cr>
        nnoremap <Plug>(unimpaired-disable)a :lua vim.notify('auto-format off', nil, { timeout=100 })<cr>:set fo-=a<cr>
        nnoremap <Plug>(unimpaired-enable)a :lua vim.notify('auto-format on', nil, { timeout=100 })<cr>:set fo+=a<cr>
        nnoremap <leader>xx <cmd>TroubleToggle<cr>
        nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
        nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>
        nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
      ]]
    end
  },

  { 'folke/which-key.nvim',
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    enabled = false,
    opts = {
    }
  },

  { 'folke/zen-mode.nvim',
    dependencies = {
      'folke/twilight.nvim',
      'reedes/vim-pencil'
    },
    init = function()
      vim.cmd[[
       nnoremap [og :ZenMode<cr>
       nnoremap ]og :ZenMode<cr>
       nnoremap yog :ZenMode<cr>
       com! -nargs=1 Goyo :lua require('zen-mode').close(); require('zen-mode').open({ window = { width = tonumber(<q-args>) }})
      ]]
    end,
    opts = {
      twilight = {
        enable = false,
      },
      options = {
        number = false,
      },
      on_open = function()
        vim.o.number = false
        vim.o.relativenumber = false
      end
    }
  },

  { 'hrsh7th/nvim-cmp',
    dependencies = {
      'onsails/lspkind.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/cmp-emoji',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        enable = (vim.env.NVIM_DISABLE_AUTOCOMPLETION == nil) and true or false,
        snippet = {
          expand = function(args)
            vim.fn['vsnip#anonymous'](args.body) -- For `vsnip` users.
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
          end, {'i','s',}),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' },
          { name = 'emoji' },
          { name = 'path' }
        }, {
          { name = 'buffer' },
        }),
        window = {
          completion = {
            winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,Search:None',
            col_offset = -3,
            side_padding = 0,
          },
        },
        formatting = {

          -- fields = { 'abbr', 'menu', 'kind' },
          -- format = function(entry, vim_item)
          --   return require('lspkind').cmp_format({ mode = 'symbol_text', maxwidth = 50 })(entry, vim_item)
          -- end,

          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            local kind = require('lspkind').cmp_format({ mode = 'symbol_text', maxwidth = 50 })(entry, vim_item)
            local strings = vim.split(kind.kind, '%s', { trimempty = true })
            kind.kind = ' ' .. strings[1] .. ' '
            kind.menu = '    (' .. strings[2] .. ')'

            return kind
          end,
        },
      })
      -- cmp.setup.cmdline('/', {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = {
      --     { name = 'buffer' }
      --   }
      -- })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          {
            name = 'cmdline',
            option = {
              ignore_cmds = { 'Man', '!' }
            }
          }
        })
      })

      function EnableCompletion()
        require('cmp').setup.buffer { enabled = true };
        vim.notify('completion enabled');
        vim.b.completion_enabled = true;
      end
      function DisableCompletion()
        require('cmp').setup.buffer { enabled = false };
        vim.notify('completion disabled');
        vim.b.completion_enabled = false;
      end
      function ToggleCompletion()
        if vim.b.completion_enabled
          then DisableCompletion()
          else EnableCompletion()
          end
      end
      vim.cmd([[
        imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
        smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
        imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
        smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
        nnoremap <Plug>(unimpaired-disable)<Tab> :lua DisableCompletion()<cr>
        nnoremap <Plug>(unimpaired-enable)<Tab> :lua EnableCompletion()<cr>
        nnoremap <Plug>(unimpaired-toggle)<Tab> :lua ToggleCompletion()<cr>
      ]])
    end,
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
    init = function()
      vim.g.fzf_command_prefix = 'Fzf'
    end,
    config = function()
      vim.cmd[[
        " <C-/> or <C-_> to toggle preview window
        " customize fzf colors to match color scheme
        let g:fzf_colors =
        \ { 'fg':      ['fg', 'Normal'],
          \ 'bg':      ['bg', 'Normal'],
          \ 'hl':      ['fg', 'Comment'],
          \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
          \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
          \ 'hl+':     ['fg', 'Statement'],
          \ 'info':    ['fg', 'PreProc'],
          \ 'border':  ['fg', 'Ignore'],
          \ 'prompt':  ['fg', 'Conditional'],
          \ 'pointer': ['fg', 'Exception'],
          \ 'marker':  ['fg', 'Keyword'],
          \ 'spinner': ['fg', 'Label'],
          \ 'header':  ['fg', 'Comment'] }

        function! RipgrepFzf(query, fullscreen, preview)
          " let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s | awk --field-separator=: ''{ x=$1; sub("/.*/", "/.../", x); print (x":"$2":"$3":"$4); }'' || true'
          let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
          let initial_command = printf(command_fmt, shellescape(a:query))
          let reload_command = printf(command_fmt, '{q}')
          let l:history_file = '/var/tmp/' . substitute(getcwd(), '/', '%', 'g') . '.ripgrep.fzf-history'
          let spec = {'options': ['--disabled', '--query', a:query, '--bind', 'change:reload:'.reload_command, '--history='.l:history_file ]}
          let spec = a:preview ? fzf#vim#with_preview(spec) : spec
          call fzf#vim#grep(initial_command, 1, spec, a:fullscreen)
        endfunction

        command! -nargs=* -bang Rg call RipgrepFzf(<q-args>, <bang>0, 1)
        command! -nargs=* -bang RgNoPreview call RipgrepFzf(<q-args>, <bang>0, 0)
        :nnoremap <leader>F     :Rg!<Enter>
        :nnoremap <C-F>         :Rg<Enter>

        "search for word in working directory
        :nnoremap <Leader>sw    :FzfRg  <Enter>
        :vnoremap <Leader>s     y:FzfRg "<Enter>

        com! -bang FzfBuffersCustom call fzf#vim#buffers
        " command! -bar -bang -nargs=? -complete=buffer FzfBuffers       call fzf#vim#buffers(<q-args>, fzf#vim#with_preview({ "placeholder": "{1}" }), <bang>0)
          command! -bar -bang -nargs=? -complete=buffer FzfBuffersCustom call fzf#vim#buffers(<q-args>, fzf#vim#with_preview({ "placeholder": "{1}", "options": ['--bind', 'ctrl-k:up', '--bind', 'ctrl-y:preview-up'] }), <bang>0)

        :nnoremap <silent> <C-k>         :FzfBuffersCustom<Enter>
        :nnoremap <silent> <C-p>         :FzfFiles<Enter>
        :nnoremap <silent> <Leader>or    :FzfHistory<Enter>
        :nnoremap <silent> <Leader>oR    :FzfHistory!<Enter>
        :nnoremap <silent> <Leader>ft    :FzfFiletypes<enter>
        :nnoremap <silent> <Leader>f/    :FzfHistory/<Enter>
        :nnoremap <silent> <Leader>f:    :FzfHistory:<Enter>
        " (note - you can call histdel("cmd", "regexp") to delete mistaken history items)

        " fuzzy relative filepath completion!
        inoremap <expr> <c-x><c-f> fzf#vim#complete#path(
              \ "find . -path '*/\.*' -prune -o -print \| sed '1d;s:^..::'",
              \ fzf#wrap({'dir': expand('%:p:h')}))
        inoremap <c-x>F <c-x><c-f>
              " Ctrl-X Shift-F will provide native c-x c-f functionality

        if (!executable('fzf') && !empty(glob("~/.fzf/bin")))
          " Save fzf from downloading a redundant binary (it's common for GUI vims
          " to not see fzf in the PATH)
          let $PATH=$PATH..":"..expand("~/.fzf/bin")
        endif
      ]]
    end
  },

  { 'karb94/neoscroll.nvim',
    opts = {
    },
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

  { 'kyazdani42/nvim-tree.lua',
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
    dependencies = dev_icons_enabled and {
      'nvim-tree/nvim-web-devicons'
    } or {},
    -- cmd = {
    --   'NvimTreeFindFile',
    --   'NvimTreeRefresh',
    --   'NvimTreeToggle',
    -- },
    init = function()
      -- "It is strongly advised to eagerly disable netrw, due to race conditions at vim startup."
      -- vim.g.loaded_netrw = 0
      vim.g.loaded_netrwPlugin = 1
      vim.cmd([[
        :nnoremap <silent> <Leader>tt :NvimTreeToggle<cr>
        :nnoremap <silent> <Leader>tf :NvimTreeFindFile<CR>
        :nnoremap <silent> <Leader>tr :NvimTreeRefresh<CR>
        " :nnoremap <silent> - :NvimTreeFindFile<CR><c-w><c-o>
      ]])
    end,
    opts = {
      renderer = {
        indent_markers = {
          enable = true,
        },
      },
      hijack_cursor = true,
      -- hijack_directories = {
      --   enable = true,
      -- },
      hijack_netrw = true,
      disable_netrw = false,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      view = {
        adaptive_size = true,
        relativenumber = false,
      },
      on_attach = function (bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set('n', '[g', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
        vim.keymap.set('n', ']g', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
      end
    },
  },

  { 'lewis6991/gitsigns.nvim',
    -- Gitsigns toggle_word_diff
    -- Gitsigns toggle_current_line_blame
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        map('n', '<leader>ga', gs.stage_hunk)
        map('v', '<leader>ga', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
        map('n', '<leader>gr', gs.reset_hunk)
        map('v', '<leader>gr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
        -- TODO alternative to fugutive diff???
        -- map('n', '<leader>GD', function() gs.diffthis('~') end)
        -- map('n', '<leader>GD', gs.diffthis)
        -- map('n', '<leader>GB', function() gs.blame_line{full=true} end)
        -- map('n', '<leader>GTB', gs.toggle_current_line_blame)
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true})
        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true})
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end
    },
  },

  'nanotee/zoxide.vim',

  { 'neovim/nvim-lspconfig',
    dependencies = {
      'folke/neodev.nvim'
    },
    config = function()
      require("neodev").setup({
        override = function(root_dir, library)
          local tail_dir = string.match(root_dir, '[^/]+/?$')
          if (string.find(root_dir, '%.config/nvim') or tail_dir == 'dotfiles') then
            library.enabled = true
            library.plugins = true
          else
            vim.notify('vim lua development (neodev) is not enabled')
          end
        end,
      })

      local lspconfig = require('lspconfig')
      ---@diagnostic disable-next-line: unused-local
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
        nnoremap_buffer('<space>oi', '<cmd>lua vim.lsp.buf.execute_command({command = "_typescript.organizeImports", arguments = {vim.fn.expand("%:p")}})<CR>', opts)
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

      ENABLE_FRONTEND_LSPS()
      ENABLE_LSP_SERVER('vimls')
      ENABLE_LSP_SERVER('bashls')
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
        !brew install lua-language-server
        " sumnekko_lua
        !npm install --global yaml-language-server
        " yamlls
      ]])
    end,
  },

  { 'norcalli/nvim-colorizer.lua',
    opts = {},
  },

  { 'nvim-lualine/lualine.nvim',
    dependencies = dev_icons_enabled and {
      'nvim-tree/nvim-web-devicons'
    } or {},
    opts = {
      extensions = {
        'fugitive',
        'fzf',
        'nvim-tree',
        'quickfix',
        'trouble',
      },
      options = {
        -- component_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {{ 'searchcount', maxcount=999, timeout=500 }, 'encoding', 'fileformat', 'filetype', },
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
    }
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
    config = function()
      require'nvim-treesitter.configs'.setup {
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
          'graphql',
          'groovy',
          'html',
          'java',
          'javascript', 'tsx', 'typescript', -- not sure if these overlap/conflict
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
      'html', 'prisma',
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

  { 'rcarriga/nvim-notify',
    config = function()
      require('notify').setup({
        render='minimal'
      })
    end,
    init = function()
      vim.notify = require('notify')
    end
  },

  { 'rest-nvim/rest.nvim',
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require('rest-nvim').setup({
      })
    end,
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        group = 'init.lua',
        pattern = 'http',
        callback = function()
          vim.keymap.set('n', '<leader>rr', function()
            require('rest-nvim').run()
          end, { buffer = 0 })
        end,
      })
    end
  },

  'rktjmp/lush.nvim',

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
            ":Git commit ",
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

  { 'stevearc/dressing.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    opts = {
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
        telescope = require('telescope.themes').get_cursor({}),

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
    },
  },

  { 'stevearc/oil.nvim',
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
          ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          ["g\\"] = "actions.toggle_trash",
        }

        local result = vim.tbl_extend('force', default_keymaps, {
          ["<C-v>"] = "actions.select_vsplit",
          ["<C-x>"] = "actions.select_split",
          ["gp"] = "actions.preview",
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
    },
    config = function()
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
        augroup END
        com! Gstashes :Gclog -g stash
        vnoremap <leader>gl :GBrowse!<cr><cr>:lua vim.notify("<c-r>+")<cr>
        nnoremap <leader>gl :GBrowse!<cr><cr>:lua vim.notify("<c-r>+")<cr>
      ]]
    end
  },

  'tpope/vim-projectionist',

  'tpope/vim-repeat',

  'tpope/vim-rsi',

  'tpope/vim-speeddating',

  { 'tpope/vim-surround',
    config = function()
      vim.cmd[[
        " NORMAL MODE:
        "   ds<SURROUND> to delete surround
        "   cs<SURROUND><SURROUND> to change surround from/to
        "   ys<TEXT-OBJECT><SURROUND> to surround text object
        "   yS<TEXT-OBJECT><SURROUND> to surround text object on new line
        "
        "   cstt<NEW-TAG> to change tag name!
        " VISUAL MODE:
        "   S<SURROUND>
        " INSERT MODE:
        "   <C-g>s<SURROUND>
        let b:surround_{char2nr('b')} = '**\r**'
        augroup vimrc_surround
          autocmd!
          autocmd FileType markdown let b:surround_{char2nr('b')} = '**\r**'
          " use 'b' to surround something with double asterisks
        augroup END
      ]]
    end
  },

  'tpope/vim-unimpaired',

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

  { 'windwp/nvim-autopairs',
    config = true
  },
})

-- https://www.reddit.com/r/neovim/comments/nrz9hp/can_i_close_all_floating_windows_without_closing/
function CloseFloatingWindows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win);
    if config.relative ~= "" then vim.api.nvim_win_close(win, false);
      print('Closing window', win)
    end
  end
end
vim.cmd[[
  com! CloseFloatingWindows lua CloseFloatingWindows()
  nnoremap <silent> <leader>dc :silent CloseFloatingWindows<cr>
]]

vim.opt.foldlevelstart = tonumber(vim.env['NVIM_OPT_FOLDLEVELSTART']) or 99
vim.opt.relativenumber = 'true' == vim.env['NVIM_OPT_RELATIVENUMBER']

-- draw a box around text
-- memonic: "you surround til $ with _"
vim.keymap.set('n', 'ys$_', function()
  local x = vim.fn.col('.')
  vim.cmd.normal('i│ ')
  vim.cmd.normal('A │')
  vim.cmd.normal('yyP'..x..'|r┌lv$hhr─$r┐j')
  vim.cmd.normal('p'..x..'|r└lv$hhr─$r┘k')
  vim.cmd.normal('|'..x..'ll')
end)


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
local function run_command_in_kitty_window(str, opts)
  opts = vim.tbl_extend('force', {
    return_focus = true,
    transient_shell = false,
  }, opts or {})

  local function create_or_focus_window()
    if (opts.transient_shell) then
      vim.fn.system({'kitty', '@', 'launch', '--cwd', vim.fn.getcwd(), '--location', 'hsplit', '--title', '🏃'})
      return kitty.get_current_window_id()
    else
      if (window_id_of_persistent_shell == nil or not kitty.window_exists(window_id_of_persistent_shell)) then
        -- if (last_terminal == nil or 0 ~= os.execute("kitty @ ls | jq '.[].tabs.[].windows.[].title' | grep --quiet 🏃")) then
        vim.fn.system({'kitty', '@', 'launch', '--cwd', vim.fn.getcwd(), '--location', 'hsplit', '--title', '🏃'})
        window_id_of_persistent_shell = kitty.get_current_window_id()
      else
        vim.fn.system({'kitty', '@', 'focus-window', '--match', 'id:'..window_id_of_persistent_shell})
      end
      return window_id_of_persistent_shell
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
vim.keymap.set('n', '<leader>.q', function() run_command_in_kitty_window('exit') end)
vim.keymap.set('n', '<leader>.>', function() run_command_in_kitty_window(nil, { return_focus = false}) end)
vim.keymap.set('n', '<leader>gt', function() run_command_in_kitty_window(nil, { return_focus = false}) end)
vim.keymap.set('n', '<leader>.<leader>', ':PersistentShell ')
vim.api.nvim_create_user_command('TransientShell', function(opts)
  local str = table.concat(opts.fargs, ' ')
  str = str .. ' && exit'
  run_command_in_kitty_window(str, {
    return_focus = not opts.bang,
    transient_shell = true,
  })
end, { nargs = '*', bang = true})
vim.api.nvim_create_user_command('PersistentShell', function(opts)
  local str = table.concat(opts.fargs, ' ')
  run_command_in_kitty_window(str, {
    return_focus = true
  })
end, { nargs = '*' })
vim.api.nvim_create_user_command('K', function(opts)
  local str = table.concat(opts.fargs, ' ')
  local return_focus = not opts.bang
  if (not return_focus) then
    str = str .. '; exit'
  end
  run_command_in_kitty_window(str, {
    return_focus = return_focus
  })
end, { nargs = '*', bang = true})


-- ┌──────────────┐
-- │ Test runners │
-- └──────────────┘
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = {'*.java'},
  group = 'init.lua',
  callback = function()
    vim.api.nvim_buf_create_user_command(0, 'TestFile', function()
      vim.cmd.update()
      run_command_in_kitty_window(string.format('gw test --tests %s', vim.fn.expand('%:t:r')), { transient_shell = true })
    end, { nargs = 0})
    vim.api.nvim_buf_create_user_command(0, 'TestOne', function()
      vim.cmd.update()
      local cursor_pos = vim.api.nvim_win_get_cursor(0);
      vim.fn.search('@\\(Parameterized\\)\\?Test', 'b')
      vim.fn.search('void ')
      vim.cmd.normal('W')
      local test_name=vim.fn.expand('<cword>')
      run_command_in_kitty_window(string.format('gw test --tests %s.%s', vim.fn.expand('%:t:r'), test_name), { transient_shell = true })
      vim.api.nvim_win_set_cursor(0, cursor_pos);
    end, { nargs = 0})
    vim.keymap.set('n', '<leader>rt', ':TestOne<cr>', { buffer = 0 })
    vim.keymap.set('n', '<leader>rf', ':TestFile<cr>', { buffer = 0 })
  end
})
