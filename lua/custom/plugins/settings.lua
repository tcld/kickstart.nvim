-- custom settings
vim.o.incsearch = true      -- show search-results while typing
vim.o.expandtab = true      -- insert spaces instead of tabs
vim.o.relativenumber = true -- enable relative line numbering
vim.o.cursorline = true     -- highlight the text line of the cursor
vim.o.title = true          -- set window title to document title for easy differentiation

-- force the UI language to be english; no lua alternative
vim.api.nvim_command('language en_US.UTF-8')

vim.keymap.set('n', '<leader>mj', ':%!python -m json.tool<CR>', { desc = 'Format [J]SON' })

return {}
