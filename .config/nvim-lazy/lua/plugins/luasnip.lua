return {
	"L3MON4D3/LuaSnip",
	-- follow latest release.
  lazy = true,
  event = "InsertEnter",
	version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
	-- install jsregexp (optional!).
	build = "make install_jsregexp"
}
