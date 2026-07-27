-- gitsigns.nvim 是一個用於顯示 Git 狀態的插件，它會在編輯器的左側顯示一些符號，用於表示文件的狀態，例如新增、修改、刪除等。這個插件的配置非常簡單，只需要設置一些基本的選項即可。
-- 熱鍵設定：
-- - ]g：下一個 Git Hunk
-- - [g：上一個 Git Hunk
-- - <space>gp：預覽 Git Hunk
-- - <space>gs：將 Git Hunk 加入暫存區
-- - <space>gr：重置 Git Hunk
-- - <space>gu：撤銷暫存 Git Hunk
-- - <space>gb：Blame Line
-- - <space>gd：Diff This
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "│" },
			change = { text = "│" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		signcolumn = true,
		numhl = false,
		linehl = false,
		word_diff = false,

		current_line_blame = true,
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol", -- 顯示在行尾 (End of Line)
			delay = 300, -- [建議] 改快一點 (原本 500ms 有點慢)，300ms 比較跟手
			ignore_whitespace = false,
		},
		-- [選用] 自訂顯示格式
		current_line_blame_formatter = "\t  <author>, <author_time:%Y-%m-%d> - <summary>",
	},
	keys = {
		{
			"]g",
			function()
				require("gitsigns").next_hunk()
			end,
			desc = "Next Git Hunk",
		},
		{
			"[g",
			function()
				require("gitsigns").prev_hunk()
			end,
			desc = "Previous Git Hunk",
		},
		{
			"<space>gp",
			function()
				require("gitsigns").preview_hunk()
			end,
			desc = "Preview Git Hunk",
		},
		{
			"<space>gs",
			function()
				require("gitsigns").stage_hunk()
			end,
			desc = "Stage Git Hunk",
		},
		{
			"<space>gr",
			function()
				require("gitsigns").reset_hunk()
			end,
			desc = "Reset Git Hunk",
		},
		{
			"<space>gu",
			function()
				require("gitsigns").undo_stage_hunk()
			end,
			desc = "Undo Stage Hunk",
		},
		{
			"<space>gb",
			function()
				require("gitsigns").blame_line({ full = true })
			end,
			desc = "Blame Line",
		},
		{
			"<space>gd",
			function()
				require("gitsigns").diffthis()
			end,
			desc = "Diff This",
		},
	},
}
