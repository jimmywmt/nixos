-- snacks.nvim: 極致的工具集合, 並且使用Lua編寫, 速度飛快, 功能豐富
-- 取代: nvim-tree, lazygit.nvim, project.nvim, nvim-notify, alpha-nvim, noice.nvim, telescope.nvim, yanky.nvim 等等
--
-- -- 在 dashboard 配置的最上方定義一個寬度檢查函式
local function is_wide()
	-- 獲取目前視窗的寬度
	return vim.o.columns > 125
end

return {
	"folke/snacks.nvim",
	priority = 1000, -- 確保最先載入
	lazy = false,
	---@type snacks.Config
	opts = {
		-- 1. 取代 lazygit.nvim
		lazygit = {
			-- 自動設定 lazygit 的主題顏色與 Neovim 同步
			configure = true,
		},

		-- 2. 取代 nvim-notify (漂亮的通知)
		notifier = { enabled = true },

		-- 3. 取代 alpha (啟動頁)
		dashboard = {
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{
					icon = " ",
					desc = "Hot Keys",
					key = "H",
					action = ":e ~/.config/nvim/docs/hotkey.md",
					padding = 1,
				},
				{ section = "startup" },
				{
					pane = 2,
					enabled = is_wide,
					section = "terminal",
					-- 使用 cat << 'EOF' 確保 ASCII 原汁原味輸出，不會被 shell 解析掉特殊字元
					cmd = [[cat << 'EOF'
|     .-.
|   /   \         .-.    󱘗  󰬷 󰌝  󰌠 󰢱 󰍔
|   /     \       /   \       .-.     .-.     _   _
+--/-------\-----/-----\-----/---\---/---\---/-\-/-\/\/---
| /         \   /       \   /     '-'     '-'
|/           '-'         '-'             
EOF]],
					height = 6,
					padding = 1,
					hl = "DiagnosticInfo",
				},
				{
					pane = 2,
					enabled = is_wide,
					icon = " ",
					title = "Recent Files",
					section = "recent_files",
					limit = 10,
					indent = 2,
					padding = 1,
				},
				{
					pane = 2,
					enabled = is_wide,
					icon = " ",
					title = "Git Status",
					section = "terminal",
					enabled = function()
						return Snacks.git.get_root() ~= nil
					end,
					cmd = "git status --short --branch --renames",
					height = 5,
					padding = 1,
					ttl = 5 * 60,
					indent = 3,
				},
				{
					pane = 2,
					enabled = is_wide,
					icon = " ",
					title = "Time",
					section = "terminal",
					-- 直接呼叫系統 date 指令
					-- %Y-%m-%d 是日期，%H:%M 是時間
					cmd = [[date "+%Y-%m-%d %H:%M"]],
					height = 2,
					indent = 5,
					hl = "DiagnosticInfo",
				},
			},
		},

		-- 4. 其他實用小工具
		bigfile = { enabled = true }, -- 大檔案自動優化
		quickfile = { enabled = true },
		statuscolumn = { enabled = true }, -- 左側行號欄美化
		words = { enabled = true }, -- 游標下單字高亮
		input = { enabled = true }, -- 更漂亮的 input 對話框
		picker = { enabled = true },
		scroll = { -- 取代平滑滾動插件
			enabled = true,
			mouse = true, -- 開啟滑鼠/觸控板平滑滾動支援
			animate = {
				duration = { step = 15, total = 250 }, -- 毫秒為單位，這組數據非常適合開發節奏
				easing = "inOutCubic",
			},
		},

		terminal = {
			win = {
				style = "float", -- 既然是 Snacks，彈出式（float）最能展現它的過分速度
				border = "rounded",
				width = 0.9,
				height = 0.9,
				keys = {
					-- [修正] 使用 function 呼叫 hide()，比 "close" 字串更安全，
					-- 確保只是隱藏視窗，不會誤殺 Shell 行程。
					["<Esc><Esc>"] = {
						function()
							Snacks.terminal.toggle()
						end,
						desc = "Hide Terminal",
						mode = { "n", "t" },
					},
				},
			},
		},
	},
	keys = {
		-- [File Explorer] 一鍵呼叫，徹底取代 nvim-tree.lua
		{
			"<localleader>fl",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},

		-- [Git] 開啟 LazyGit (取代原插件)
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},

		-- [Project] 開啟專案選擇 (取代 project.nvim)
		{
			"<localleader>fP",
			function()
				Snacks.picker.projects()
			end,
			desc = "Projects",
		},

		-- [Notify] 查看通知歷史
		{
			"<localleader>fn",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Notification History",
		},

		-- [File] 快速重新命名檔案
		{
			"<localleader>rf",
			function()
				Snacks.rename.rename_file()
			end,
			desc = "Rename File",
		},

		{
			"<localleader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Find Files",
		},

		{
			"<localleader>fg",
			function()
				Snacks.picker.grep()
			end,
			desc = "Live Grep",
		},

		{
			"<localleader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Find Buffers",
		},

		{
			"<localleader>fh",
			function()
				Snacks.picker.help()
			end,
			desc = "Find Help Tags",
		},

		{
			"<localleader>fd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Find Diagnostics",
		},

		{
			"<localleader>fq",
			function()
				Snacks.picker.files({ cwd = "~/.config/nvim/docs" })
			end,
			mode = "n",
			desc = "Find files in ~/.config/nvim/docs",
		},
		-- 取代原本 yanky 的功能
		{
			"<localleader>fp",
			function()
				Snacks.picker.registers()
			end,
			desc = "Show Yank History / Registers",
		},
		-- [Terminal] 一鍵呼叫，徹底取代 ToggleTerm
		{
			"gm",
			function()
				Snacks.terminal.toggle()
			end,
			desc = "Toggle Terminal",
		},
		{
			"<space><space>",
			function()
				local ft = vim.bo.filetype
				local menu_items = {
					{
						group = "Lazy.nvim",
						items = {
							{ "Update Plugins", "Lazy update" },
							{ "Sync Plugins", "Lazy sync" },
							{ "Check Plugin Health", "Lazy health" },
							{ "Clean Unused Plugins", "Lazy clean" },
							{ "Show Plugin Log", "Lazy log" },
							{ "Open Lazy UI", "Lazy" },
						},
					},
					{
						group = "Session & Project",
						items = {
							{
								"▶️ Start Auto-Save (本局啟用)",
								function()
									require("persistence").start()
									vim.notify("✅ 已開啟背景自動存session", vim.log.levels.INFO)
								end,
							},
							{
								"⏸️ Stop Auto-Save (本局暫停)",
								function()
									require("persistence").stop()
									vim.notify("🚫 已暫停背景自動存session", vim.log.levels.WARN)
								end,
							},
							{
								"Restore Last Session",
								function()
									require("persistence").load()
								end,
							},
							{
								"Switch/Delete Session",
								function()
									-- 1. 直接讀取 persistence 儲存 Session 的實體目錄
									local session_dir = vim.fn.stdpath("state") .. "/sessions/"
									local files = vim.fn.glob(session_dir .. "*.vim", true, true)
									local items = {}

									-- 2. 解析檔名，還原成您看得懂的專案路徑
									for _, file in ipairs(files) do
										local name = vim.fn.fnamemodify(file, ":t:r"):gsub("%%", "/")
										table.insert(items, { text = name, file = file })
									end

									if #items == 0 then
										vim.notify("No sessions found", vim.log.levels.WARN)
										return
									end

									-- 3. 呼叫底層 Snacks Picker 引擎，這次我們擁有絕對控制權
									Snacks.picker.pick({
										title = "📂 Switch (Enter) / Delete (Ctrl-X)",
										items = items,
										format = function(item)
											return { { item.text } }
										end,
										layout = {
											preset = "vscode",
											preview = false,
											layout = { height = 25, row = 5 },
										},
										actions = {
											-- 💡 真正的刪除邏輯寫在這裡
											delete_session = function(picker, item)
												if not item then
													return
												end
												os.remove(item.file)
												vim.notify(
													"🗑️ 已刪除 Session: " .. item.text,
													vim.log.levels.WARN
												)
												picker:close()
											end,
											-- 💡 覆寫 Enter 鍵，直接 source 該 Session 檔案
											confirm = function(picker, item)
												picker:close()
												vim.cmd("silent! source " .. vim.fn.fnameescape(item.file))
												vim.notify("🚀 Session Restored: " .. item.text)
											end,
										},
										win = {
											input = {
												keys = {
													-- 💡 將 Ctrl-x 綁定到我們上面寫好的 delete_session
													["<C-x>"] = { "delete_session", mode = { "n", "i" } },
												},
											},
										},
									})
								end,
							},
							{
								"Save Current Session",
								function()
									require("persistence").save()
								end,
							},
						},
					},
					{
						group = "Diffview",
						items = {
							{ "HEAD~1", "DiffviewOpen HEAD~1" },
							{ "HEAD~2", "DiffviewOpen HEAD~2" },
							{ "Close", "DiffviewClose" },
						},
					},
					{
						group = "Spell & Style",
						items = {
							{ "Enable LTeX (Spell)", "LtexPlusStart" },
							{ "Disable LTeX (Spell)", "LtexPlusStop" },
							{
								"Toggle Harper (Style)",
								function()
									local client = vim.lsp.get_clients({ name = "harper_ls" })[1]
									if client then
										vim.lsp.stop_client(client.id)
										vim.notify("🚫 Harper-ls Stopped", vim.log.levels.WARN)
									else
										vim.cmd("HarperStart")
									end
								end,
							},
						},
					},
					{
						group = "Golang",
						ft = "go",
						items = {
							{ "Build", "GoBuild" },
							{ "Run", "GoRun" },
							{ "Test", "GoTest" },
							{ "CoverageToggle", "GoCoverageToggle" },
							{ "Generate Test File", "GoTests" },
						},
					},
					{ group = "Markdown", ft = "markdown", items = { { "PreviewToggle", "MarkdownPreviewToggle" } } },
				}

				-- 轉換成 Snacks 格式
				local items = {}
				for _, section in ipairs(menu_items) do
					if not section.ft or section.ft == ft then
						for _, item in ipairs(section.items) do
							table.insert(items, {
								text = string.format("[%s] %s", section.group, item[1]),
								cmd = item[2],
							})
						end
					end
				end

				-- 呼叫底層 Snacks Picker 引擎
				Snacks.picker.pick({
					title = "🚀 Quick Command Menu",
					items = items, -- 底層引擎會自動抓取 items 裡的 text 屬性，不需要 format！
					layout = {
						preset = "vscode", -- 享受沒有高度限制的大視窗
						preview = false, -- 關閉預覽視窗
						layout = {
							height = 25, -- 直接給定 25 列，或是設為 0.6 (代表螢幕高度的 60%)
							row = 5,
						},
					},
					format = function(item)
						-- 外層是陣列，內層是區塊。我們不需要特別上色，所以只給文字即可
						return { { item.text } }
					end,
					actions = {
						-- 覆寫按下 Enter 時的預設行為
						confirm = function(picker)
							local item = picker:current()
							if not item then
								return
							end

							-- 先關閉選單
							picker:close()

							-- 執行您的指令邏輯
							if type(item.cmd) == "function" then
								item.cmd()
							else
								vim.cmd(item.cmd)
							end
						end,
					},
				})
			end,
			desc = "Open Snacks Quick Menu",
		},
	},
}
