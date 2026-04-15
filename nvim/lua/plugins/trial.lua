
return {
  { 'dhruvasagar/vim-table-mode',
    init = function()
      vim.g.table_mode_corner='|'
    end,
  },
  { "monaqa/dial.nvim",
  config = function()
    local augend = require("dial.augend")
    require("dial.config").augends:register_group {
      default = {
        augend.constant.alias.bool,
        augend.integer.alias.decimal_int,
        augend.date.alias["%d.%m.%Y"],
      },

    }
    -- vim.keymap.set("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true })
    -- vim.keymap.set("n", "<C-x>", require("dial.map").dec_normal(), { noremap = true })
    vim.keymap.set("n", "<C-a>", function()
        require("dial.map").manipulate("increment", "normal")
    end)
    vim.keymap.set("n", "<C-x>", function()
        require("dial.map").manipulate("decrement", "normal")
    end)
    vim.keymap.set("n", "g<C-a>", function()
        require("dial.map").manipulate("increment", "gnormal")
    end)
    vim.keymap.set("n", "g<C-x>", function()
        require("dial.map").manipulate("decrement", "gnormal")
    end)
    vim.keymap.set("x", "<C-a>", function()
        require("dial.map").manipulate("increment", "visual")
    end)
    vim.keymap.set("x", "<C-x>", function()
        require("dial.map").manipulate("decrement", "visual")
    end)
    vim.keymap.set("x", "g<C-a>", function()
        require("dial.map").manipulate("increment", "gvisual")
    end)
    vim.keymap.set("x", "g<C-x>", function()
        require("dial.map").manipulate("decrement", "gvisual")
    end)
  end
}
}
