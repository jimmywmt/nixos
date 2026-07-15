-- lua/plugins/noice.lua
-- 取代 fine-cmdline.nvim
-- 我們只用它來接管 Command Line 的 UI，其他功能全部關閉，
-- 讓 Snacks 負責通知，Fidget 負責 LSP 進度。

return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		-- "rcarriga/nvim-notify", -- 我們不需要這個，因為用 snacks.notifier
	},
	opts = {
		-- 1. 核心：接管 Cmdline 和 Popupmenu
		cmdline = {
			enabled = true,
			view = "cmdline_popup", -- 類似 fine-cmdline 的中央浮動視窗
			format = {
				-- 讓它看起來像 VS Code 的帥氣介面
				cmdline = { pattern = "^:", icon = "", lang = "vim" },
				search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
				search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
			},
		},
		popupmenu = {
			enabled = true, -- 讓 blink.cmp 的補全選單可以正確附著在 cmdline 上
			backend = "nui", -- 使用 nui 來繪製漂亮的選單
		},

		-- 2. 關閉通知 (交給 Snacks)
		notify = {
			enabled = false,
		},

		-- 3. 關閉 LSP 進度 (交給 Fidget)
		lsp = {
			progress = {
				enabled = false,
			},
			-- 覆蓋原本的 vim.notify 和 vim.lsp.handlers
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
			signature = {
				enabled = false, -- 我們已經有 blink 的 signature 了
			},
		},

		-- 4. 訊息過濾 (選用)
		-- 避免一些無聊的 "written" 訊息洗版
		routes = {
			-- 攔截存檔訊息 (written)
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "written",
				},
				opts = { skip = true },
			},
		},
	},
	-- 確保這東西接管 :
	keys = {
		{
			"<S-Enter>",
			function()
				require("noice").redirect(vim.fn.getcmdline())
			end,
			mode = "c",
			desc = "Redirect Cmdline",
		},
	},
}
