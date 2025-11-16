local constants = require("utils.constants")
local dev_icons_enabled = os.getenv('VIM_DEVICONS') == '1'
return {
  { 'folke/trouble.nvim',
    --[[
      | P | toggle preview           |
      | o | open file, close trouble |
    ]]
    enabled = true,
    dependencies = {
      'tpope/vim-unimpaired', -- for "<Plug>(unimpaired-toggle)" keybindings
    },
    cmd = "Trouble",
    opts = {
      focus = true,
      auto_refresh = false,
      win = {
        position = 'bottom',
        -- border = 'rounded',
        -- type = 'float',
        title_pos = 'center',
        title = 'Usages',
        relative = 'editor',
        size = { width = 0.9, height = 0.3 },
      },
      preview = {
        type = "split",
        relative = "win",
        position = "right",
        size = 0.5,
      },
    },
    keys = {
      { '<leader>xq', '<cmd>Trouble qflist toggle<cr>',                   desc = 'Quickfix List (Trouble)',      },
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>',              desc = 'Diagnostics (Trouble)',        },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)', },
    },
    init = function()
      vim.cmd[[
        nnoremap ]t :lua require("trouble").next({skip_groups = true, jump = true})<cr>
        nnoremap [t :lua require("trouble").prev({skip_groups = true, jump = true})<cr>
      ]]
    end
  },

  { 'folke/which-key.nvim',
    event = "VeryLazy",
    init = function()
      require('which-key').setup({
        preset = 'helix',
        delay = function(ctx)
          return ctx.plugin and 0 or 800
        end,
      })
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require('which-key').add {
        -- { '<leader>q', name = 'Session stuff?', _ = 'which_key_ignore' },
        -- { '<leader>bd', name = 'Backups', _ = 'which_key_ignore' },
      }
    end,
    enabled = false,
  },

  { 'folke/zen-mode.nvim',
    dependencies = {
      'folke/twilight.nvim',
      'reedes/vim-pencil'
    },
    cmd = { 'Twighlight '},
    init = function()
      vim.cmd[[
       " nnoremap [og :ZenMode<cr>:PencilSoft<cr>
       " nnoremap ]og :ZenMode<cr>:PencilOff<cr>
       nnoremap yog :ZenMode<cr>:PencilToggle<cr>
       com! -nargs=1 Goyo :lua require('zen-mode').close(); require('zen-mode').open({ window = { width = tonumber(<q-args>) }})
      ]]
    end,
    keys = {
      { '[og', function()
        if (vim.b.zen_mode == true) then
          vim.notify("Zen mode is already active active", vim.log.levels.ERROR)
          return
        end
        vim.b.zen_mode = true
        require('zen-mode').open()
        vim.cmd.PencilSoft()
        if (vim.env.TERM == "xterm-kitty") then
          vim.system(vim.split('kitty @ set-spacing padding=16', ' ')) --:wait()
          -- vim.system(vim.split('kitty @ set-font-size -- +1', ' ')) --:wait()
        end
      end },
      { ']og', function()
        if (vim.b.zen_mode == nil) then
          vim.notify("Zen mode is already inactive", vim.log.levels.ERROR)
          return
        end
        vim.b.zen_mode = nil
        require('zen-mode').close()
        vim.cmd.PencilOff()
        if (vim.env.TERM == "xterm-kitty") then
          vim.system(vim.split('kitty @ set-spacing padding=0', ' ')) --:wait()
          -- vim.system(vim.split('kitty @ set-font-size -- -1', ' ')) --:wait()
        end
      end }
    },
    opts = {
      options = {
        number = false,
      },
      kitty = {
        enabled = true,
        font = "+4", -- font size increment
      },
      on_open = function()
        vim.o.number = false
        vim.o.relativenumber = false
      end,
      plugins = {
        twilight = {
          enabled = false,
        },
      },
    },
  },
  { 'j-hui/fidget.nvim',
    setup = function()
      vim.notify = require('fidget.notification').notify
    end,
    opts = {
      notification = {
      },
    },
    init = function()
      vim.notify = require('fidget').notify
    end
  },

  { 'karb94/neoscroll.nvim',
    opts = {
      mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
        '<C-u>', '<C-d>',
        '<C-b>', -- '<C-f>',
        '<C-y>', '<C-e>',
        'zt', 'zz', 'zb',
      },
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
        vim.keymap.set('n', '[g', api.node.navigate.diagnostics.prev, opts('Go to prev diagnostic'))
        vim.keymap.set('n', ']g', api.node.navigate.diagnostics.next, opts('Go to next diagnostic'))
      end
    },
  },

  { 'nvim-lualine/lualine.nvim',
    enabled = not vim.g.vscode,
    dependencies = dev_icons_enabled and {
      'nvim-tree/nvim-web-devicons'
    } or {},
    opts = function()

      local macro_recording = function()
        local reg_recording = vim.fn.reg_recording();
        if (reg_recording == '') then
          return ''
        end
        return "RECORDING "..reg_recording
      end

      return {
        extensions = {
          'fugitive',
          'fzf',
          'lazy',
          'nvim-tree',
          'oil',
          'quickfix',
          'trouble',
        },
        options = {
          -- component_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { {macro_recording, color={bg='red'}}, 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { { 'searchcount', maxcount=999, timeout=500 }, 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'selectioncount', 'location'}
        },
      }
    end,
    init = function()
      local refresh = function()
        vim.defer_fn(function()
          require('lualine').refresh()
        end, 1)
      end
      vim.api.nvim_create_autocmd({'RecordingLeave', 'RecordingEnter'}, {
        callback = refresh
      })
    end,
  },

  {
    'nvim-mini/mini.pick',
    opts = {
    },
    keys = function()
      local keys = {
      }
      if (constants.FILE_PICKER == constants.FILE_PICKERS.mini) then
        vim.list_extend(keys, {
          {"<c-p>", mode = "n", function() MiniPick.builtin.files({ tool = 'git' }) end, desc = "Pick file"},
        })
      end
      return keys
    end,
  },

  { 'nvim-telescope/telescope.nvim',
    dependencies = 'neovim/nvim-lspconfig',
  },
}
