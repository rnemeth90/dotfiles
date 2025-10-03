return {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic", -- or "basic" / "off"
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
      },
    },
  },
}
