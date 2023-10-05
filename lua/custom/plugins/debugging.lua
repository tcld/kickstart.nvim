---@private
local function get_python_path()
  -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
  -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
  -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
  local cwd = vim.fn.getcwd()
  if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
    return cwd .. '/venv/bin/python'
  elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
    return cwd .. '/.venv/bin/python'
  else
    return '/usr/bin/python'
  end
end

return {
  -- general debug adapter
  -- for adding debuggers and further configuration, see :help dap.txt
  'mfussenegger/nvim-dap',
  config = function()
    local dap = require('dap')
    dap.adapters.python = function(on_config_callback, dap_config)
      if dap_config.request == 'attach' then
        ---@diagnostic disable-next-line: undefined-field
        local port = (dap_config.connect or dap_config).port
        ---@diagnostic disable-next-line: undefined-field
        local host = (dap_config.connect or dap_config).host or '127.0.0.1'
        on_config_callback({
          type = 'server',
          port = assert(port, '`connect.port` is required for a python `attach` configuration'),
          host = host,
          options = {
            source_filetype = 'python',
          },
        })
      else
        on_config_callback({
          type = 'executable',
          command = os.getenv('HOME') .. '/.local/venv/debugpy/bin/python', -- python -m venv debugpy; cd debugpy; source bin/activate.fish; pip install debugpy
          args = { '-m', 'debugpy.adapter' },
          options = {
            source_filetype = 'python',
          },
        })
      end
    end

    dap.configurations.python = {
      {
        -- The first three options are required by nvim-dap
        type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = 'launch', -- either 'attach' or 'launch'
        name = 'Launch file', -- user-readable name for this configuration

        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
        program = '${file}', -- The current file.
        pythonPath = get_python_path,
      },
      {
        -- The first three options are required by nvim-dap
        type = 'python',
        request = 'launch',
        name = 'Launch file with arguments',

        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
        program = '${file}',
        args = function()
          local args_string = vim.fn.input('Arguments: ')
          return vim.split(args_string, " +")
        end,
        pythonPath = get_python_path,
      },
      {
        -- The first three options are required by nvim-dap
        type = 'python',
        request = 'attach',
        name = 'Attach to remote process',

        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
        connect = function()
          local host = vim.fn.input('Host [127.0.0.1]: ')
          host = host ~= '' and host or '127.0.0.1'
          local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
          return { host = host, port = port }
        end,
      },
      {
        -- The first three options are required by nvim-dap
        type = 'python',
        request = 'attach',
        name = 'Attach to local process',

        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
        processId = "${command:pickProcess}",
        justMyCode = true,
        logToFile = true,
      },
    }

    -- replace some of the debug signs
    vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})
    vim.fn.sign_define('DapBreakpointCondition', {text='⬡', texthl='', linehl='', numhl=''})

    -- use active debug session to ask for auto completion candidates
    require('dap.ext.autocompl').attach()

    -- default suggested keymapping
    -- vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
    -- vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
    -- vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
    -- vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
    -- vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
    -- vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
    -- vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
    -- vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
    -- vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
    -- vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
    --   require('dap.ui.widgets').hover()
    -- end)
    -- vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
    --   require('dap.ui.widgets').preview()
    -- end)
    -- vim.keymap.set('n', '<Leader>df', function()
    --   local widgets = require('dap.ui.widgets')
    --   widgets.centered_float(widgets.frames)
    -- end)
    -- vim.keymap.set('n', '<Leader>ds', function()
    --   local widgets = require('dap.ui.widgets')
    --   widgets.centered_float(widgets.scopes)
    -- end)

    -- keymapping (none are enabled by default)
    vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Continue' })
    vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Step Over' })
    vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, { desc = 'Step Into' })
    vim.keymap.set('n', '<F12>', function() require('dap').step_out() end, { desc = 'Step Out' })
    vim.keymap.set('n', '<Leader>bB', function() require('dap').toggle_breakpoint() end, { desc = 'Toggle [B]reakpoint' })
    vim.keymap.set('n', '<Leader>bb', function() require('dap').set_breakpoint() end, { desc = 'Set [b]reakpoint' })
    vim.keymap.set('n', '<Leader>bl', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { desc = 'Set [l]ogged breakpoint' })
    vim.keymap.set('n', '<Leader>br', function() require('dap').repl.open() end, { desc = 'Open [r]epl' })
    vim.keymap.set('n', '<Leader>bl', function() require('dap').run_last() end, { desc = 'Run [l]ast' })
    vim.keymap.set({'n', 'v'}, '<Leader>bh', function()
      require('dap.ui.widgets').hover()
    end, { desc = '[h]over' })
    vim.keymap.set({'n', 'v'}, '<Leader>bp', function()
      require('dap.ui.widgets').preview()
    end, { desc = '[p]review' })
    vim.keymap.set('n', '<Leader>bf', function()
      local widgets = require('dap.ui.widgets')
      widgets.centered_float(widgets.frames)
    end, { desc = '[f]rames' })
    vim.keymap.set('n', '<Leader>bs', function()
      local widgets = require('dap.ui.widgets')
      widgets.centered_float(widgets.scopes)
    end, { desc = '[s]copes' })

    -- ##################### custom mode vim example #####################
    -- NOTE: requires https://github.com/kana/vim-submode
    -- " Create a submode to handle windows
    -- " The submode is entered whith <Leader>k and exited with <Leader>
    -- call submode#enter_with('WindowsMode', 'n', '', '<Leader>k', ':echo "windows mode"<CR>')
    -- call submode#leave_with('WindowsMode', 'n', '', '<Leader>')
    -- " Change of windows with hjkl
    -- call submode#map('WindowsMode', 'n', '', 'j', '<C-w>j')
    -- call submode#map('WindowsMode', 'n', '', 'k', '<C-w>k')
    -- call submode#map('WindowsMode', 'n', '', 'h', '<C-w>h')
    -- call submode#map('WindowsMode', 'n', '', 'l', '<C-w>l')
    -- " Resize windows with <C-yuio> (interesting on azerty keyboards)
    -- call submode#map('WindowsMode', 'n', '', 'u', '<C-w>-')
    -- call submode#map('WindowsMode', 'n', '', 'i', '<C-w>+')
    -- call submode#map('WindowsMode', 'n', '', 'y', '<C-w><')
    -- call submode#map('WindowsMode', 'n', '', 'o', '<C-w>>')
    -- " Move windows with <C-hjkl>
    -- call submode#map('WindowsMode', 'n', '', '<C-j>', '<C-w>J')
    -- call submode#map('WindowsMode', 'n', '', '<C-k>', '<C-w>K')
    -- call submode#map('WindowsMode', 'n', '', '<C-h>', '<C-w>H')
    -- call submode#map('WindowsMode', 'n', '', '<C-l>', '<C-w>L')
    -- " close a window with c
    -- call submode#map('WindowsMode', 'n', '', 'c', '<C-w>c')
    -- " split windows with / and !
    -- call submode#map('WindowsMode', 'n', '', '/', '<C-w>s')
    -- call submode#map('WindowsMode', 'n', '', '!', '<C-w>v')
    -- 
    -- let g:submode_keep_leaving_key = 0
    -- let g:submode_timeout = 0

    -- ##################### much more primitive setup: #####################
    -- dap.adapters.python = {
    --   type = 'executable',
    --   command = os.getenv('HOME') .. '/.local/venv/debugpy/bin/python', -- python -m venv debugpy; cd debugpy; source bin/activate.fish; pip install debugpy
    --   args = { '-m', 'deb;gpy.adapter' }, -- TODO: Which debugger is debugpy using in the background? pdb? ipdb?
    --   args = { '-m', 'debugpy.adapter' },
    -- }
    -- dap.configurations.python = {
    --   {
    --     type = 'python',
    --     request = 'launch',
    --     name = 'Launch file',
    --
    --     program = '${file}',
    --     pythonPath = function()
    --       return '/usr/bin/python'
    --     end,
    --   },
    -- }
  end
}
