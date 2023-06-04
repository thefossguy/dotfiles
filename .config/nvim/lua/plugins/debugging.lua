local dap = require('dap')

dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- yes, this binary is provided by 'lldb'
  name = 'lldb',
}

dap.configurations.rust = {
  name = 'Launch lldb',
  type = 'lldb',
  request = 'launch',
  program = function()
    return vm.fn.input(
    'Path to executable: ',
    vim.fn.getcwd() .. '/',
    'file'
    )
  end,
  cwd = '${workspaceFolder}',
  stopOnEntry = false,
  args = {},
  runInTerminal = false,
}

vim.keymap.set('n', '<leader>c',  dap.continue,          { desc = 'DAP: [c]ontinue' })
vim.keymap.set('n', '<leader>so', dap.step_over,         { desc = 'DAP: [s]tep [o]ver' })
vim.keymap.set('n', '<leader>si', dap.step_into,         { desc = 'DAP: [s]tep [i]nto' })
vim.keymap.set('n', '<leader>sO', dap.step_out,          { desc = 'DAP: [s]tep [O]ut' })
vim.keymap.set('n', '<leader>tb', dap.toggle_breakpoint, { desc = 'DAP: [t]oogle [b]reakpoint' })
vim.keymap.set('n', '<leader>sb', dap.set_breakpoint,    { desc = 'DAP: [s]et [b]reakpoint' })
vim.keymap.set('n', '<leader>ro', dap.repl.open,         { desc = 'DAP: [r]epl [o]pen' })
vim.keymap.set('n', '<leader>rl', dap.run_last,          { desc = 'DAP: [r]un [l]ast' })
