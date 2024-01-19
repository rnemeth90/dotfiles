local status_ok, nvim_dap = pcall(require, "nvim-dap")
if not status_ok then
  return
end

local status_ok, nvim_dap_ui = pcall(require, "nvim-dapui")
if not status_ok then
  return
end

require("dap-go").setup()

nvim_dap.adapters.python = {
  type = 'executable';
  command = os.getenv('HOME') .. '/.virtualenvs/tools/bin/python';
  args = { '-m', 'debugpy.adapter' };
}

