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

  -- File explorer
  'stevearc/oil.nvim',

  -- Coding related
  'numToStr/Comment.nvim',

}


------------------------------------------
--- Simple Config
------------------------------------------

require("oil").setup({
  view_options = {
    show_hidden = true,
  },
})

