-- markdown-preview 是一個可以在 Neovim 中預覽 markdown 文件的插件
-- 熱鍵設定：
-- - <localleader>mp: 開啟 markdown 預覽
-- - <localleader>mt: 切換 markdown 預覽
-- - <localleader>ms: 關閉 markdown 預覽
return {
	"iamcco/markdown-preview.nvim",
	-- 💡 加上 --shamefully-hoist，讓 pnpm 允許幽靈相依性 (Hoisting)
	build = "cd app && pnpm install --shamefully-hoist",
	ft = { "markdown" },
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	config = function()
		vim.g.mkdp_auto_start = 0
		vim.g.mkdp_auto_close = 1
		vim.g.mkdp_refresh_slow = 0
	end,
	keys = {
		{ "<localleader>mp", "<cmd>MarkdownPreview<CR>", desc = "Markdown Preview", mode = "n" },
		{ "<localleader>mt", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown Toggle", mode = "n" },
		{ "<localleader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Markdown Stop", mode = "n" },
	},
}
