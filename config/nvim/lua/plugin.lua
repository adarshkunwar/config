----------------------------------------
--- Bootstrap lazy.nvim
------------------------------------------

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------
--- Plugins (Simple sets)
------------------------------------------

require('lazy').setup {
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Zen mode
  'junegunn/goyo.vim',

  --null-ls & prettier
  'jose-elias-alvarez/null-ls.nvim',
  'MunifTanjim/prettier.nvim',

  -- Dev icon
  'nvim-tree/nvim-web-devicons',

  -- Comment with gcc
  'numToStr/Comment.nvim',

  -- nvim lint, and indentation
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  require("config.cmp"),

  require("config.lspconfig"),

  require("config.telescope"),
  
  require("config.conform"),

  require("config.gruvbox"),

  require("config.ufo"),

  require("config.harpoon"),

  require("config.gitsigns"),

  require("config.lint"),

  require("config.oil"),

  require("config.treesitter"),

  require("config.autopairs"),

  require("config.snacks")
}

