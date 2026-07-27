-- gopher.nvim 是為 Go 語言開發的輕量級插件，提供 struct tags 修改、if err 生成等工具
-- 並搭配 Snacks 實現現代化的 Go Run / Go Build
--
-- 熱鍵設定 (只在 Go 檔案生效)：
-- - <localleader>gs: 添加 json struct tags (Gopher)
-- - <localleader>ge: 生成 if err != nil (Gopher)
-- - <localleader>r : Go Run (透過 Snacks)
-- - <localleader>b : Go Build (透過 Snacks)

return {
	"olexsmir/gopher.nvim",
	ft = "go",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("gopher").setup({
			commands = {
				go = "go",
				gomodifytags = "gomodifytags",
				impl = "impl",
				iferr = "iferr",
			},
		})
	end,
	keys = {
		-- Gopher 工具類功能
		{
			"<localleader>gs",
			"<cmd>GoTagAdd json<cr>",
			ft = "go",
			desc = "Add json struct tags",
		},
		{
			"<localleader>gS",
			"<cmd>GoTagRm json<cr>",
			ft = "go",
			desc = "Remove json struct tags",
		},
		{
			"<localleader>ge",
			"<cmd>GoIfErr<cr>",
			ft = "go",
			desc = "Add if err != nil",
		},

		-- 替代 vim-go 的核心功能：Run & Build
		{
			"<localleader>rr",
			function()
				Snacks.terminal.toggle("go run .")
			end,
			ft = "go",
			desc = "Go Run (Project)",
		},
		{
			"<localleader>rb",
			function()
				Snacks.terminal.toggle("go build")
			end,
			ft = "go",
			desc = "Go Build (Project)",
		},

		-- 為了保持習慣，可以暫時保留一個簡單的 go test，直到 neotest 上線
		-- 如果不想現在佔用 <localleader>t，可以把下面這行註解掉
		-- { "<localleader>t", "<cmd>TermExec cmd='go test ./...' direction=horizontal<cr>", ft = "go", desc = "Go Test (Simple)" },
	},
}
