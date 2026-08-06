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

		-- 💡 針對 Marp 與簡報預覽調整的選單選項
		vim.g.mkdp_preview_options = {
			marlight = 0, -- 關閉 marlight 主題（讓 Marp 的自訂 CSS/Theme 能正常作用）
			katex = {}, -- 啟用 KaTeX（數學公式）
			uml = {}, -- 啟用 PlantUML/Diagrams
			maid = {}, -- 啟用 Mermaid 圖表
			disable_sync_scroll = 0, -- 保留雙向同步滾動 (1 為關閉)
			sync_scroll_type = "middle",
			hide_yaml_meta = 1, -- 隱藏開頭的 YAML Front-matter (marp: true 等)
			sequence_diagrams = {},
			flowchart_diagrams = {},
			content_editable = false,
			disable_filename_in_page = 0,
		}
	end,
	keys = {
		{ "<localleader>mp", "<cmd>MarkdownPreview<CR>", desc = "Markdown Preview", mode = "n" },
		{ "<localleader>mt", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown Toggle", mode = "n" },
		{ "<localleader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Markdown Stop", mode = "n" },
	},
}
