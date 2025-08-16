-- Leader first
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Environment & core UI options early
vim.fn.setenv("COLORFGBG", nil)        -- avoid terminal hint flipping bg
vim.opt.termguicolors = true

-- Pick ONE: dark or light. Keep this consistent with the theme config below.
vim.opt.background = "light"            -- <-- change to "light" if you want Solarized Light

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git","--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- THEME (load first)
  {
    "shaunsingh/solarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- keep background consistent with the top-level choice
      -- vim.o.background = "light"  -- <-- use this instead if you want Light
      vim.o.background = vim.opt.background:get()
      vim.cmd.colorscheme("solarized")
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "swift", "lua", "vim", "json", "markdown" },
      highlight = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- Telescope
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Statusline (optional)
  { "nvim-lualine/lualine.nvim", opts = {} },

  -- Comments
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function() require("Comment").setup() end,
  },

  -- LSP + completion
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      -- nvim-cmp minimal setup
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = { { name = "nvim_lsp" }, { name = "buffer" } },
      })

      local caps = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      local sourcekit_path = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp"

      lspconfig.sourcekit.setup({
        cmd = { sourcekit_path },
        capabilities = caps,
        -- root_dir = lspconfig.util.root_pattern("*.xcodeproj", "Package.swift", ".git"),
      })
    end
    }
}, {
  defaults = { lazy = true },
})

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- Telescope keymaps
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- Comment toggles
vim.keymap.set("n", "<leader>/", function() require("Comment.api").toggle.linewise.current() end, { desc = "Toggle comment" })
vim.keymap.set("v", "<leader>/", function()
  local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
end, { desc = "Toggle comment" })

