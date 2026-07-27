-- -- nvim-ufo 是一個可以自動折疊程式碼的插件，可以自動折疊程式碼，並且可以自動折疊註解，讓你的程式碼更加簡潔。
-- -- 熱鍵設定：
-- -- - zF: 打開所有折疊
-- -- - zf: 關閉所有折疊
-- -- - za: 切換折疊 (內建功能)
return {
	"kevinhwang91/nvim-ufo",
	dependencies = { "kevinhwang91/promise-async" },
	event = "BufReadPost",
	config = function()
		vim.o.foldcolumn = "1"
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true

		require("ufo").setup({
			provider_selector = function(bufnr, filetype, buftype)
				-- 1. 守門員：如果是 "nofile" (Hover, LSP 視窗) 或 終端機，直接禁用折疊
				if buftype == "nofile" or buftype == "terminal" then
					return ""
				end

				-- 2. [修正] 回歸簡單暴力：只回傳 {"lsp", "indent"}
				-- 這是最穩定的組合。如果不幸 LSP 沒反應，至少還有縮排可以折疊。
				-- 這樣就符合 "don't add providers more than two" 的限制了。
				return { "lsp", "indent" }
			end,
		})
	end,
	keys = {
		{
			"zF",
			function()
				require("ufo").openAllFolds()
			end,
			desc = "Open all folds",
		},
		{
			"zf",
			function()
				require("ufo").closeAllFolds()
			end,
			desc = "Close all folds",
		},
	},
}
