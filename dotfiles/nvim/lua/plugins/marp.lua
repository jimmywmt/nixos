-- marp.nvim 是一個可以在 Neovim 中將 markdown 渲染為 16:9 投影片的插件
-- 熱鍵設定：
-- - <localleader>po: 開啟 marp 簡報預覽
-- - <localleader>pc: 關閉 marp 簡報預覽
return {
	"nwiizo/marp.nvim",
	ft = "markdown",
	config = function()
		require("marp").setup({
			marp_command = { "npx", "@marp-team/marp-cli@latest" },
			allow_local_files = true,
			brower = nil,
		})
	end,
	keys = {
		{ "<localleader>po", "<cmd>MarpWatch<cr>", desc = "Start Marp Preview" },
		{ "<localleader>pc", "<cmd>MarpStop<cr>", desc = "Stop Marp Preview" },
	},
}
