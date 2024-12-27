return {
  require("lspconfig").clangd.setup({
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "hpp" },
  }),
}
