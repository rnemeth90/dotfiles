vim.g.python_host_prog = "~/.pynvim_env/bin/python"
vim.g.python3_host_prog = "~/.pynvim_env/bin/python"

return {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
}
