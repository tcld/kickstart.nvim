return {
  -- filemanager that provides integration for whatever file manager I have installed
  -- i.e.: ":Ranger" is now a command.
  -- { 'is0n/fm-nvim', opts = {} },
  { 'kelly-lin/ranger.nvim', opts = function()
      vim.keymap.set('n', '<leader>f', function()
        require('ranger-nvim').open(true)
      end, { desc = 'Open Ranger [f]ilemanager' })

      return {
        enable_cmds = true, -- enable `:Ranger`
        replace_netrw = false, -- replace vim's builtin filemanager (doesn't seem to work)
        keybinds = { -- These keybindings are in ranger-syntax, not vim-syntax!
          ['ov'] = require('ranger-nvim').OPEN_MODE.vsplit,
          ['oh'] = require('ranger-nvim').OPEN_MODE.split,
          ['ot'] = require('ranger-nvim').OPEN_MODE.tabedit,
          -- ['or'] = require('ranger-nvim').OPEN_MODE.rifle,
        },
        ui = {
          border = 'none',
          height = 1,
          width = 1,
          x = 0.5,
          y = 0.5,
        }
      }
    end
  },
}
