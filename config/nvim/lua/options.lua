------------------------------------------
--- Map leader and clipboard
------------------------------------------

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.clipboard = 'unnamedplus'

------------------------------------------
--- Base Options
------------------------------------------

local opt = vim.opt

-- Title options
opt.title = false

-- Line number
opt.number = true
opt.relativenumber = true

-- Tab options & Indent
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.breakindent = true

-- Don't show mode (handled by statusline)
opt.showmode = false

-- Persistent undo
opt.undofile = true

-- Search behavior
opt.ignorecase = true
opt.smartcase = true

-- Always show the sign column
opt.signcolumn = 'yes'

-- Faster time
opt.updatetime = 250
opt.timeoutlen = 300

-- Split behavior
opt.splitright = true
opt.splitbelow = true

-- Whitespace visualization
opt.list = true
opt.listchars = {
  tab = '▸ ',
  trail = '·',
  nbsp = '␣',
}

-- Live substitution preview (Neovim ≥ 0.7)
opt.inccommand = 'split'

-- Highlight current line
opt.cursorline = true

-- Keep context around cursor
opt.scrolloff = 10

-- Ignore node_modules in file completion
opt.wildignore:append '*/node_modules/*'
