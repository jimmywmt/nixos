-- flash.nvim 是一個用來快速跳轉的插件，可以用來跳轉到指定單詞、字符、兩個字符、Treesitter 節點等
-- 熱鍵設定：
-- - <localleader><localleader>w: 跳轉到指定單詞
-- - <localleader><localleader>b: 跳轉到指定單詞（反向）
-- - <localleader><localleader>l: 跳轉到指定字符
-- - <localleader><localleader>h: 跳轉到指定字符（反向）
-- - <localleader><localleader>tl: 跳轉到指定兩個字符
-- - <localleader><localleader>th: 跳轉到指定兩個字符（反向）
-- - <localleader><localleader>ts: 跳轉到 Treesitter 節點
-- - <localleader><localleader>r: 跨視窗跳轉
return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		labels = "asdfghjklqwertyuiopzxcvbnm1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ",
		modes = {
			char = {
				jump_labels = true,
			},
		},
	},
	keys = {
		-- Word 跳轉（類似 HopWord）
		{
			"<localleader><localleader>w",
			function()
				require("flash").jump({ search = { mode = "search", forward = true, wrap = false } })
			end,
			desc = "Flash Word Forward",
			mode = { "n", "v" },
		},
		{
			"<localleader><localleader>b",
			function()
				require("flash").jump({ search = { mode = "search", forward = false, wrap = false } })
			end,
			desc = "Flash Word Backward",
			mode = { "n", "v" },
		},

		-- 單字元跳轉（類似 HopChar1）
		{
			"<localleader><localleader>l",
			function()
				require("flash").jump({ mode = "char", search = { forward = true, wrap = false } })
			end,
			desc = "Flash Char Forward",
			mode = { "n", "v" },
		},
		{
			"<localleader><localleader>h",
			function()
				require("flash").jump({ mode = "char", search = { forward = false, wrap = false } })
			end,
			desc = "Flash Char Backward",
			mode = { "n", "v" },
		},

		-- 兩字元跳轉（類似 HopChar2）
		{
			"<localleader><localleader>tl",
			function()
				require("flash").jump({ search = { max_length = 2, forward = true, wrap = false } })
			end,
			desc = "Flash 2-Char Forward",
			mode = { "n", "v" },
		},
		{
			"<localleader><localleader>th",
			function()
				require("flash").jump({
					search = {
						max_length = 2,
						forward = false,
						wrap = false,
					},
				})
			end,
			desc = "Flash 2-Char Backward",
			mode = { "n", "v" },
		},
		-- Treesitter 節點跳轉
		{
			"<localleader><localleader>ts",
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
			mode = { "n", "v" },
		},
		-- Remote 跳轉（跨視窗）
		{
			"<localleader><localleader>r",
			function()
				require("flash").remote()
			end,
			desc = "Flash Remote (cross-window)",
			mode = { "n", "v" },
		},
	},
}
