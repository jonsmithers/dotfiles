-- vim: ts=2 sw=2
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
vim.cmd('source ' .. vim.env.HOME .. '/.config/nvim/init2.vim')

local dev_icons_enabled = os.getenv('VIM_DEVICONS') == '1'

require('lazy').setup({

  { 'airblade/vim-gitgutter',
    -- I use vim-signify in lieu of gitgutter because it's faster. However,
    -- gitgutter has a killer feature to stage the hunk under cursor. So I
    -- disable every aspect of gitgutter, and temporarily enable it just when I
    -- want to use this feature.
    cmd = 'GitGutterEnable',
    init = function()
      vim.cmd[[
        :nmap <silent> <Leader>ga :GitGutterEnable<cr>:GitGutterStageHunk<cr>:GitGutterDisable<cr>:SignifyRefresh<cr>:echo 'staged hunk'<cr>
      ]]
    end,
    config = function()
      vim.g.gitgutter_enabled = 0
      vim.g.gitgutter_signs = 0
      vim.g.gitgutter_async = 0
      vim.g.gitgutter_map_keys = 0
    end
  },

  { 'folke/which-key.nvim' },

  { 'folke/trouble.nvim',
    config = function()
      vim.cmd[[
        nnoremap <leader>xx <cmd>TroubleToggle<cr>
        nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
        nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>
        nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
      ]]
    end
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

      vim.cmd([[
        imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
        smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
        imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
        smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
      ]])
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
        :nnoremap <silent> <Leader>or    :FzfHistory!<Enter>
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

  { 'junegunn/goyo.vim',
    dependencies = {
      'junegunn/limelight.vim',
      'reedes/vim-pencil'
    },
    config = function()
      vim.cmd[[
       nnoremap [og :Goyo<cr>
       nnoremap ]og :Goyo!<cr>
       nnoremap yog :Goyo<cr>
       let g:goyo_width = 81
       " make vim close the First time you do :quit
       " https://github.com/junegunn/goyo.vim/wiki/Customization
       function! s:goyo_enter()
         lua require('lualine').hide()
         let b:quitting = 0
         let b:quitting_bang = 0
         Limelight
         SoftPencil
         if (exists(':LspDisableCompletion'))
           LspDisableCompletion
           silent! CloseFloatingWindows
         endif
         augroup goyo_buffer
           au!
           autocmd QuitPre <buffer> let b:quitting = 1
         augroup END
         cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
       endfunction
       function! s:goyo_leave()
         Limelight!
         NoPencil
         if (exists(':LspEnableCompletion'))
           LspEnableCompletion
           silent! CloseFloatingWindows
         endif
         " Quit Vim if this is the only remaining buffer
         if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
           if b:quitting_bang
             qa!
           else
             qa
           endif
         endif
         lua require('lualine').hide({unhide = true})
       endfunction
       augroup goyo_stuff
         au!
         autocmd User GoyoEnter call <SID>goyo_enter()
         autocmd User GoyoLeave call <SID>goyo_leave()
       augroup END
      ]]
    end
  },

  { 'karb94/neoscroll.nvim',
    opts = {
    },
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
    cmd = {
      'NvimTreeFindFile',
      'NvimTreeRefresh',
      'NvimTreeToggle',
    },
    init = function()
      vim.cmd([[
        :nnoremap <silent> <Leader>tt :NvimTreeToggle<cr>
        :nnoremap <silent> <Leader>tf :NvimTreeFindFile<CR>
        :nnoremap <silent> <Leader>tr :NvimTreeRefresh<CR>
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
      hijack_netrw = false,
      disable_netrw = false,
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      sync_root_with_cwd = true,
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

  'nelstrom/vim-visual-star-search',

  { 'neovim/nvim-lspconfig',
    dependencies = {
      'folke/neodev.nvim'
    },
    config = function()
      require("neodev").setup({})
      vim.cmd([[
        com! LspDisableCompletion lua require('cmp').setup.buffer { enabled = false }; vim.notify('completion disabled')
        com! LspEnableCompletion lua require('cmp').setup.buffer { enabled = true }; vim.notify('completion enabled')
        nnoremap <Plug>(unimpaired-enable)L :LspEnableCompletion<cr>
        nnoremap <Plug>(unimpaired-disable)L :LspDisableCompletion<cr>
        nnoremap <Plug>(unimpaired-enable)<c-space> :LspEnableCompletion<cr>
        nnoremap <Plug>(unimpaired-enable)<c-space> :LspDisableCompletion<cr>
        " 👆 <c-space> no longer works for some reason
      ]])

      local lspconfig = require('lspconfig')
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

  { 'mhinz/vim-signify'
    -- ]c,[c | next git item
  },

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

  { 'rcarriga/nvim-notify',
    config = function()
      require('notify').setup({
        render='minimal'
      })
      vim.notify = require('notify')
    end
  },

  'rktjmp/lush.nvim',

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
        augroup END
      ]]
    end
  },

  'tpope/vim-projectionist',

  'tpope/vim-repeat',

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

  { 'windwp/nvim-autopairs',
  config = true
  },
})
