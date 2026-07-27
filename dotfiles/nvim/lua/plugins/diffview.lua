-- DiffView 是一個用於比較文件差異的插件，它提供了一個簡單的界面，讓我們可以方便地查看文件的差異。
-- 它支持多種比較工具，如 vimdiff、diff、ediff、meld、kdiff3、tkdiff 等
-- 熱鍵設定:
-- <localleader>do: 打開 DiffView
-- <localleader>de: 關閉 DiffView
-- <localleader>dh: 查看文件歷史
return {
	"sindrets/diffview.nvim",
	event = "BufRead", -- 在讀取 buffer 時載入
	dependencies = { "nvim-lua/plenary.nvim" }, -- 依賴 plenary.nvim
	keys = {
		{ "<localleader>do", "<CMD>DiffviewOpen<CR>", desc = "Open DiffView" },
		{ "<localleader>de", "<CMD>DiffviewClose<CR>", desc = "Close DiffView" },
		{ "<localleader>dh", "<CMD>DiffviewFileHistory<CR>", desc = "File History" },
	},
	config = function()
		require("diffview").setup({
			view = {
				merge_tool = {
					layout = "diff3_horizontal", -- 設定合併工具的顯示方式
				},
			},
			hooks = {
				diff_buf_read = function(bufnr)
					vim.bo[bufnr].bufhidden = "delete" -- 自動清理 buffer
				end,
			},
		})
	end,
}
