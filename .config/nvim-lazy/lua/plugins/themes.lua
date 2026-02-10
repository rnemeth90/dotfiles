-- Themes
return {
	"typicode/bg.nvim",
	"ellisonleao/gruvbox.nvim",
	{
		"catppuccin/nvim",
		name = "catppuccin",
	},
	{
		"rose-pine/nvim",
		name = "rose-pine",
	},
	"sainnhe/everforest",
	"savq/melange-nvim",
  {
    "navarasu/onedark.nvim",
    priority = 1000, -- make sure to load this before all the other start plugins
    name = "onedark",
    config = function()
      require('onedark').setup {
        style = 'darker'
      }
      require('onedark').load()
    end
  }
}
