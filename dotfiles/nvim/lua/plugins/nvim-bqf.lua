-- nvim-bqf 是一個用於增強 quickfix 窗口的插件
return {
	"kevinhwang91/nvim-bqf",
	ft = "qf", -- 只在 quickfix buffer 啟動
	config = function()
		require("bqf").setup({
			auto_enable = true,
			preview = {
				auto_preview = true,
				win_height = 15,
				win_vheight = 15,
				delay_syntax = 50,
				border = "rounded",
			},
			func_map = {
				open = "<CR>",
				openc = "o",
				drop = "O",
				split = "s",
				vsplit = "v",
				tab = "t",
				tabdrop = "T",
				toggle_mode = "m",
				toggle_preview = "p",
				scroll_up = "<C-u>",
				scroll_down = "<C-d>",
				preview_scroll_up = "<C-b>",
				preview_scroll_down = "<C-f>",
			},
			filter = {
				fzf = {
					action_for = {
						["ctrl-s"] = "split",
						["ctrl-v"] = "vsplit",
						["ctrl-t"] = "tab",
					},
					extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
				},
			},
		})
	end,
}
