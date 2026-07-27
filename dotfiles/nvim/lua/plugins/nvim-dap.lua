-- nvim-dap 是一個用來調試代碼的插件，它支持多種語言，並且可以自定義調試配置
-- 熱鍵設定：
-- - <localleader>du: 切換 DAP UI
-- - <localleader>db: 切換斷點
-- - <localleader>dB: 設置條件斷點
-- - <F5>: 開始/繼續調試
-- - <F6>: 進入函數
-- - <F7>: 跳出函數
-- - <F8>: 跳出堆棧
-- - <F9>: 運行上一個調試配置
-- - <F10>: 關閉調試器
-- - <localleader>dgt: 調試 Go 測試
-- - <localleader>tdc: DAP 命令
-- - <localleader>tdC: DAP 配置
-- - <localleader>tdb: 斷點列表
-- - <localleader>tdv: DAP 變量
-- - <localleader>tdf: DAP 堆棧

return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
		"leoluz/nvim-dap-go",
	},
	keys = {
		-- UI 操作
		{
			"<localleader>du",
			function()
				require("dapui").toggle()
			end,
			desc = "Toggle DAP UI",
		},

		-- 斷點管理
		{
			"<localleader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle Breakpoint",
		},
		{
			"<localleader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Set Conditional Breakpoint",
		},

		-- Debug 運行
		{
			"<F5>",
			function()
				require("dap").continue()
			end,
			desc = "Start / Continue Debugging",
		},
		{
			"<F6>",
			function()
				require("dap").step_into()
			end,
			desc = "Step Into",
		},
		{
			"<F7>",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
		},
		{
			"<F8>",
			function()
				require("dap").step_out()
			end,
			desc = "Step Out",
		},
		{
			"<F9>",
			function()
				require("dap").run_last()
			end,
			desc = "Run Last Debug Configuration",
		},
		{
			"<F10>",
			function()
				require("dap").close()
				require("dap.repl").close()
				require("dapui").close()
				vim.cmd("DapVirtualTextForceRefresh")
			end,
			desc = "Close Debugger",
		},

		-- Go 調試
		{
			"<localleader>dgt",
			function()
				require("dap-go").debug_test()
			end,
			desc = "Debug Go Test",
		},

		-- Snacks Picker 整合
		{
			"<localleader>tdc",
			function()
				Snacks.picker.dap_commands()
			end,
			desc = "DAP Commands",
		},
		{
			"<localleader>tdC",
			function()
				Snacks.picker.dap_configurations()
			end,
			desc = "DAP Configurations",
		},
		{
			"<localleader>tdb",
			function()
				Snacks.picker.dap_breakpoints()
			end,
			desc = "List Breakpoints",
		},
		{
			"<localleader>tdv",
			function()
				Snacks.picker.dap_variables()
			end,
			desc = "DAP Variables",
		},
		{
			"<localleader>tdf",
			function()
				Snacks.picker.dap_frames()
			end,
			desc = "DAP Frames",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- 🎨 設定斷點圖示與高亮 (DAP Signs)
		vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = "🟡", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
		)
		vim.fn.sign_define("DapLogPoint", { text = "🟣", texthl = "DapLogPoint", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapStopped",
			{ text = "▶️", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" }
		)
		vim.fn.sign_define(
			"DapBreakpointRejected",
			{ text = "⚪", texthl = "DapBreakpointRejected", linehl = "", numhl = "" }
		)

		-- **初始化 DAP UI**
		dapui.setup({
			layouts = {
				{
					elements = {
						"scopes",
						"breakpoints",
						"stacks",
						"watches",
					},
					size = 40,
					position = "right",
				},
				{
					elements = {
						"repl",
						"console",
					},
					size = 10,
					position = "bottom",
				},
			},
		})

		-- **當 DAP 啟動或結束時，自動開關 UI**
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
			dap.repl.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
			dap.repl.close()
		end

		-- **初始化 nvim-dap-virtual-text**
		require("nvim-dap-virtual-text").setup({
			enabled = true,
			enable_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = false,
			show_stop_reason = true,
			commented = false,
			only_first_definition = true,
			all_references = false,
			filter_references_pattern = "<module",
			virt_text_pos = "eol",
			all_frames = false,
			virt_lines = false,
		})

		-- 🚀 啟動 Go DAP 支持 (會自動尋找 PATH 中的 dlv)
		require("dap-go").setup()

		-- 🚀 自動讀取 `lua/dap/` 內的所有語言設定檔
		local function load_dap_configs()
			local dap_path = vim.fn.stdpath("config") .. "/lua/dap/"
			local uv = vim.uv or vim.loop
			local scan = uv.fs_scandir(dap_path)

			if scan then
				while true do
					local name, _ = uv.fs_scandir_next(scan)
					if not name then
						break
					end

					if name:match("%.lua$") then
						local module_name = name:gsub("%.lua$", "")
						local require_name = "dap." .. module_name

						local status, lang_dap = pcall(require, require_name)
						if status and type(lang_dap) == "table" then
							-- 💡 精準合併 Adapters (key 為 adapter 名稱，如 codelldb)
							if lang_dap.adapters then
								for adapter_name, adapter_config in pairs(lang_dap.adapters) do
									dap.adapters[adapter_name] = adapter_config
								end
							end

							-- 💡 精準合併 Configurations (key 為語言名稱，如 rust / cpp)
							if lang_dap.configurations then
								for lang, config_list in pairs(lang_dap.configurations) do
									dap.configurations[lang] = config_list
								end
							end
						else
							vim.notify("Failed to load DAP config for: " .. require_name, vim.log.levels.WARN)
						end
					end
				end
			end
		end

		load_dap_configs()
	end,
}
