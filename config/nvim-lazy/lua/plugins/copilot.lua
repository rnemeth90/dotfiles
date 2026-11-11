return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	dependencies = {
		"zbirenbaum/copilot-cmp",
		"copilotlsp-nvim/copilot-lsp",
		{
			"CopilotC-Nvim/CopilotChat.nvim",
			opts = function()
				-- Path to your custom prompt file inside stdpath("config") (~/.config/nvim)
				local prompt_path = vim.fn.stdpath("config") .. "~/.config/copilot-system-prompt.md"
				local system_prompt = ""

				if vim.fn.filereadable(prompt_path) == 1 then
					-- Read file lines and join with newlines
					system_prompt = table.concat(vim.fn.readfile(prompt_path), "\n")
				else
					-- Fallback default prompt if the file doesn't exist
					system_prompt = "You are an expert software engineer. Provide concise, clean code."
				end

				return {
					system_prompt = system_prompt,
				}
			end,
		},
	},
	config = function()
		require("copilot").setup({
			suggestion = { enabled = false },
			panel = { enabled = false },
			nes = { enabled = false },
			filetypes = {
				yaml = false,
				markdown = false,
				help = false,
				gitcommit = false,
				gitrebase = false,
				hgcommit = false,
				svn = false,
				cvs = false,
				["."] = false,
			},
		})
		require("copilot_cmp").setup()
	end,
}
