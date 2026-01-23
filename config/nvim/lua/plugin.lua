----------------------------------------
--- Bootstrap lazy.nvim
---
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
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      {
        'folke/neodev.nvim',
        opts = {
          library = {
            enabled = true,
            runtime = true,
            types = true,
            plugins = true,
          },
        },
      },
    },
    config=function()
      require("config.lspconfig")
    end
  },
  { 
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make', cond = function()
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
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
  },
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },
  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opt = require("config.conform")
  },

  -- Dev icon
  'nvim-tree/nvim-web-devicons',
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.o.background = 'dark'
      vim.cmd.hi 'Comment gui=none'
      vim.cmd.colorscheme 'gruvbox'
    end,
  },

  -- Coding related
  'numToStr/Comment.nvim',
  -- Opencode ai
  {
    'kevinhwang91/nvim-ufo',
    dependencies= {
      {
        'kevinhwang91/promise-async'
      }
    },
    config = function()
      require("config.ufo")
    end

  },
  {
    'ThePrimeagen/harpoon',
    branch = "harpoon2",
    config = function()
      require("config.harpoon")
    end
  },
  {
    'hrsh7th/nvim-cmp', -- for snippets this is completion 
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      require("config.cmp")
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = require("config.treesitter"),
    config=function ()
      require('nvim-treesitter.install').prefer_git = true
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

