-- bufferline 是一個用來管理 buffer 的插件，可以用來快速切換 buffer、關閉 buffer、跳轉到指定 buffer 等功能
-- 熱鍵設定：
--  - <C-h>: 切換到上一個 buffer
--  - <C-l>: 切換到下一個 buffer
--  - <C-x>: 關閉當前 buffer
--  - <localleader><localleader>0~9: 跳轉到指定 buffer
return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy", -- 讓 bufferline 只有在需要時載入，提升啟動速度
	opts = {
		options = {
			diagnostics = "nvim_lsp", -- 使用 Neovim 內建 LSP 診斷
			offsets = { -- 為 NvimTree 留出空間
				{
					filetype = "NvimTree",
					text = "File Explorer",
					highlight = "Directory",
					text_align = "left",
				},
			},
			numbers = function(opts) -- 顯示 buffer 編號
				return string.format("%s", opts.raise(opts.ordinal))
			end,
		},
	},
	keys = {
		-- 切換 Buffer
		{ "<C-h>", "<CMD>BufferLineCyclePrev<CR>", desc = "BufferLine Previous" },
		{ "<C-l>", "<CMD>BufferLineCycleNext<CR>", desc = "BufferLine Next" },

		-- 關閉當前 Buffer
		{ "<C-x>", "<CMD>bw<CR>", desc = "Close Buffer" },

		-- 快速跳轉到指定 Buffer
		{ "<localleader><localleader>1", "<CMD>BufferLineGoToBuffer 1<CR>", desc = "Go To Buffer 1" },
		{ "<localleader><localleader>2", "<CMD>BufferLineGoToBuffer 2<CR>", desc = "Go To Buffer 2" },
		{ "<localleader><localleader>3", "<CMD>BufferLineGoToBuffer 3<CR>", desc = "Go To Buffer 3" },
		{ "<localleader><localleader>4", "<CMD>BufferLineGoToBuffer 4<CR>", desc = "Go To Buffer 4" },
		{ "<localleader><localleader>5", "<CMD>BufferLineGoToBuffer 5<CR>", desc = "Go To Buffer 5" },
		{ "<localleader><localleader>6", "<CMD>BufferLineGoToBuffer 6<CR>", desc = "Go To Buffer 6" },
		{ "<localleader><localleader>7", "<CMD>BufferLineGoToBuffer 7<CR>", desc = "Go To Buffer 7" },
		{ "<localleader><localleader>8", "<CMD>BufferLineGoToBuffer 8<CR>", desc = "Go To Buffer 8" },
		{ "<localleader><localleader>9", "<CMD>BufferLineGoToBuffer 9<CR>", desc = "Go To Buffer 9" },
		{ "<localleader><localleader>0", "<CMD>BufferLineGoToBuffer 10<CR>", desc = "Go To Buffer 10" },
	},
}
