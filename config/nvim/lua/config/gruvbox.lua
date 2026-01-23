
  return {
    'ellisonleao/gruvbox.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.o.background = 'dark'
      vim.cmd.hi 'Comment gui=none'
      vim.cmd.colorscheme 'gruvbox'
    end,
  }
