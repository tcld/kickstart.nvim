-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

require('onedark').setup({
  style = 'dark', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
  -- toggle_style_list = {'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'}, -- List of styles to toggle between
  toggle_style_list = {'warmer', 'light'},
})

-- document existing key chains/add new ones
require('which-key').register({
  ['<leader>b'] = { name = 'De[b]ugging', _ = 'which_key_ignore' },
  ['<leader>m'] = { name = '[M]isc', s = { require('onedark').toggle, 'Toggle Onedark [S]tyle' } },
})

-- NOTE: Overriding the triggers_nowait parameter only works on first setup for now, so this is actually done in the top-level init.lua.
-- require('which-key').setup({
--   triggers_nowait = {
--     -- marks
--     "`",
--     "'",
--     "g`",
--     "g'",
--     -- registers
--     '"',
--     "<c-r>",
--     -- spelling
--     "z=",
--     -- custom
--     -- ";",
--     "<leader>",
--     -- [';'] = ";",
--     -- ['<leader>'] = "<leader>",
--   },
-- })

return {}
