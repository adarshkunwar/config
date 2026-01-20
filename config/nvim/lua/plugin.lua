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
  { 
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require("config.telescope")
    end,
  },

  -- Formatting and linting
  'jose-elias-alvarez/null-ls.nvim',
  'MunifTanjim/prettier.nvim',

  -- Dev icon
  'nvim-tree/nvim-web-devicons',

  -- Coding related
  'numToStr/Comment.nvim',
  {
    'ThePrimeagen/harpoon',
    branch = "harpoon2",
    config = function()
      require("config.harpoon")
    end
  },

  -- File explorer
  {
    'stevearc/oil.nvim',
    opts = require("config.oil")
  },

  -- Git 
  {
    'lewis6991/gitsigns.nvim',
    opts = require("config.gitsigns"),
  },

}

