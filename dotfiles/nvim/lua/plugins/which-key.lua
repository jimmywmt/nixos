-- which-key.nvim 是一個用來顯示快捷鍵提示的插件，它支持多種配置，並且可以自定義快捷鍵
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
		{
			"<esc>",
			"<CMD>nohlsearch<CR>",
			desc = "No Highlight Search",
		},
	},
}
