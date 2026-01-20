------------------------------------------
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

  -- LSP (Language Server Protocol)
  'neovim/nvim-lspconfig',

  -- Formatting and linting
  'jose-elias-alvarez/null-ls.nvim',
  'MunifTanjim/prettier.nvim',

  -- Dev icon
  'nvim-tree/nvim-web-devicons',

  -- Coding related
  'numToStr/Comment.nvim',

  -- File explorer
  {
    'stevearc/oil.nvim',
    config=function()
      require("config.oil")
    end
  },

  -- Git 
  {
    'lewis6991/gitsigns.nvim',
    opts = require("config.gitsigns"),  -- load opts from a file
  },

}

