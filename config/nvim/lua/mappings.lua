-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Shorten function name
local map = vim.keymap.set
-- Silent keymap option
local opts = { silent = true, noremap = true }

--Remap space as leader key
map("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "

vim.cmd("behave mswin")

map("i", "<C-y>", "<cmd>redo<CR>", opts)
map("n", "<C-y>", "<cmd>redo<CR>", opts)
map("i", "<C-z>", "<cmd>u<CR>", opts)
map("n", "<C-z>", "<cmd>u<CR>", opts)
map("i", "<C-s>", "<cmd>w<CR>", opts)
map("n", "<C-s>", "<cmd>w<CR>", opts)
map("i", "<C-q>", "<cmd>q<CR>", opts)
map("n", "<C-q>", "<cmd>q<CR>", opts)
map("i", "<C-BS>", "<C-o>db", opts)
map("i", "<C-Delete>", "<C-o>daw", opts)
map("i", "<C-e>", "<cmd>Neotree toggle<CR>", opts)
map("n", "<C-e>", "<cmd>Neotree toggle<CR>", opts)
map("i", "<C-w>", "<cmd>Bdelete<CR>", opts)
map("i", "<C-Tab>", "<cmd>bnext<CR>", opts)
map("i", "<C-S-Tab>", "<cmd>bprev<CR>", opts)
map("n", "<C-Tab>", "<cmd>bnext<CR>", opts)
map("n", "<C-S-Tab>", "<cmd>bprev<CR>", opts)
map("n", "<C-t>", "<cmd>term<CR>", opts)
map("n", "<C-n>", "<cmd>enew<CR>", opts)
map("t", "<Esc>", "<C-\\><C-n>", opts)

-- Telescope
map("n", "<leader>fp", "<cmd>Telescope projects<CR>", opts)
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts)

