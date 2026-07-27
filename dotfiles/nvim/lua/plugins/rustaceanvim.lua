-- rustaceanvim: Rust 開發的終極插件
-- 自動整合 LSP (rust-analyzer) 和 DAP (codelldb)
-- 並繼承 lua/lsp/common.lua 的通用熱鍵設定

return {
	"mrcjkb/rustaceanvim",
	version = "^5",
	lazy = false,
	ft = { "rust" },
	config = function()
		local common = require("lsp.common")

		vim.g.rustaceanvim = {
			-- LSP 設定
			server = {
				on_attach = function(client, bufnr)
					common.on_attach(client, bufnr)

					-- 存檔自動格式化
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ bufnr = bufnr })
						end,
					})
				end,
				default_settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						checkOnSave = true,
						check = {
							command = "clippy",
						},
					},
				},
			},
			-- DAP 設定：直接透過系統 PATH 動態推算 codelldb 與 liblldb.so
			dap = {
				adapter = function()
					local cfg = require("rustaceanvim.config")
					local codelldb_path = vim.fn.exepath("codelldb")

					-- 如果系統 PATH 抓得到 codelldb (透過 home.nix 安裝)
					if codelldb_path ~= "" then
						local liblldb_path =
							vim.fn.substitute(codelldb_path, "adapter/codelldb$", "lldb/lib/liblldb.so", "")
						if vim.fn.filereadable(liblldb_path) == 1 then
							return cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
						end
						return cfg.get_codelldb_adapter(codelldb_path, "")
					end

					vim.notify("⚠️ [rustaceanvim] codelldb not found in PATH. DAP disabled.", vim.log.levels.WARN)
					return nil
				end,
			},
		}
	end,
	keys = {
		{
			"<localleader>rca",
			function()
				vim.cmd.RustLsp("codeAction")
			end,
			desc = "Rust Code Action (Grouped)",
			ft = "rust",
		},
		{
			"<localleader>rd",
			function()
				vim.cmd.RustLsp("debuggables")
			end,
			desc = "Rust Debuggables",
			ft = "rust",
		},
		{
			"<localleader>rr",
			function()
				vim.cmd.RustLsp("runnables")
			end,
			desc = "Rust Runnables",
			ft = "rust",
		},
		{
			"<localleader>rm",
			function()
				vim.cmd.RustLsp("expandMacro")
			end,
			desc = "Rust Expand Macro",
			ft = "rust",
		},
		{
			"<localleader>rh",
			function()
				vim.cmd.RustLsp("hoverActions")
			end,
			desc = "Rust Hover Actions",
			ft = "rust",
		},
	},
}
