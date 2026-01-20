vim.g.mapleader = " " -- leader key, set to Space

vim.opt.clipboard = "unnamedplus" -- use system keyboard for yank

vim.opt.nu = true -- set line numbers
vim.opt.relativenumber = true -- use relative line numbers

-- set tab size to 4 spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.incsearch = true -- incremental search

vim.opt.termguicolors = true -- colors

-- disable backups and make undotree to have access to long undo tree, basically
vim.opt.swapfile = false
vim.opt.backup = false

local undodir = vim.fn.expand(vim.fn.stdpath("data") .. "/undodir")
vim.fn.mkdir(undodir, "p")

vim.opt.undodir = undodir
vim.opt.undofile = true

-- searching
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8 -- scroll bottom padding
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"
