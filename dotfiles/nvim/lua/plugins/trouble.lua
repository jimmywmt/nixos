-- trouble.nvim 是一個顯示錯誤訊息的插件，它可以顯示錯誤訊息、警告訊息、訊息等。
-- 熱鍵設定：
-- <localleader>xx：顯示/隱藏錯誤訊息
return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{
			"<localleader>xx",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Diagnostics (Trouble)",
		},
	},
	opts = {},
}
