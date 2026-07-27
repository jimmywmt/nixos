-- neotest: 現代化的單元測試框架
-- 支援 Go, Rust 以及其他語言
--
-- 熱鍵設定：
-- <localleader>tt : 執行當前游標下的測試 (Test Nearest)
-- <localleader>tf : 執行當前檔案的所有測試 (Test File)
-- <localleader>ts : 開啟/關閉測試總覽面板 (Test Summary)
-- <localleader>to : 顯示測試輸出結果 (Test Output)
-- <localleader>tw : 開啟測試監控模式 (Watch) - 存檔自動重跑

return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- Go 語言適配器 (推薦這個版本，支援度最好)
		"fredrikaverpil/neotest-golang",
		-- Rust 不需要額外安裝適配器，rustaceanvim 已內建
	},
	config = function()
		require("neotest").setup({
			-- 設定適配器
			adapters = {
				-- Go 適配器設定
				require("neotest-golang")({
					go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
					dap_go_enabled = true, -- 支援除錯模式
				}),

				-- Rust 適配器 (直接引用 rustaceanvim 的內建功能)
				require("rustaceanvim.neotest"),
			},

			-- 介面設定
			status = { virtual_text = true },
			output = { open_on_run = true },
			quickfix = {
				open = function()
					if require("neotest").state.adapter_ids() then
						vim.cmd("copen")
					end
				end,
			},
		})
	end,
	keys = {
		{
			"<localleader>tt",
			function()
				require("neotest").run.run()
			end,
			desc = "Run Nearest Test",
		},
		{
			"<localleader>tf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Run Current File Tests",
		},
		{
			"<localleader>td",
			function()
				require("neotest").run.run({ strategy = "dap" })
			end,
			desc = "Debug Nearest Test",
		},
		{
			"<localleader>ts",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "Toggle Test Summary",
		},
		{
			"<localleader>to",
			function()
				require("neotest").output.open({ enter = true, auto_close = true })
			end,
			desc = "Show Test Output",
		},
		{
			"<localleader>tw",
			function()
				require("neotest").watch.toggle(vim.fn.expand("%"))
			end,
			desc = "Toggle Test Watch (File)",
		},
	},
}
