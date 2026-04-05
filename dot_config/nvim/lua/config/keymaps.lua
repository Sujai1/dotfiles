-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- q to quit (only if no unsaved changes)
vim.keymap.set("n", "q", "<cmd>q<cr>", { desc = "Quit (no unsaved changes)" })

-- qq to force quit without saving
vim.keymap.set("n", "qq", "<cmd>q!<cr>", { desc = "Force quit without saving" })

-- sq to save and quit
vim.keymap.set("n", "sq", "<cmd>wq<cr>", { desc = "Save and quit" })
