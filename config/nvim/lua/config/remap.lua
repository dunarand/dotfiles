-- Diagnostics
vim.keymap.set("n", "<leader>qe", vim.diagnostic.open_float, { desc = "Show diagnostic error" })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic" })

-- Pane management
vim.keymap.set("n", "<M-h>", "<C-w>h", { desc = "Move to left pane" })
vim.keymap.set("n", "<M-l>", "<C-w>l", { desc = "Move to right pane" })
vim.keymap.set("n", "<M-k>", "<C-w>k", { desc = "Move to upper pane" })
vim.keymap.set("n", "<M-j>", "<C-w>j", { desc = "Move to lower pane" })

-- Move highlighted lines/blocks up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line up" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line down" })

-- goated keybinds (theprimeagen)
vim.keymap.set("n", "J", "mzJ`z", { desc = "Add line below to end with space" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next occurence" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous occurence" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without register" })

-- Yanking
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without register" })

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set(
	"n",
	"<leader>ra",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace all under cursor" }
)

-- Splits
vim.keymap.set("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>h", "<cmd>split<CR>", { desc = "Horizontal split" })

vim.keymap.set("n", "<C-Down>", ":resize -1<CR>", { desc = "Decrease height" })
vim.keymap.set("n", "<C-Up>", ":resize +1<CR>", { desc = "Increase height" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +1<CR>", { desc = "Increase width" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -1<CR>", { desc = "Decrease width" })

-- File-wide yank, paste, etc.
vim.keymap.set("n", "<leader>sa", "ggVG", { desc = "Highlight whole file" })
vim.keymap.set("n", "<leader>sy", "ggVGy", { desc = "Yank whole file" })
vim.keymap.set("n", "<leader>sp", "ggVGp", { desc = "Paste on whole file" })
vim.keymap.set("n", "<leader>sx", "ggVGx", { desc = "Delete file contents" })
