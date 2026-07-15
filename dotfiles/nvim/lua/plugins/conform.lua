-- conform.nvim: 專注於程式碼格式化的輕量級插件
-- 取代 none-ls 的 formatting 功能
-- 熱鍵：<leader>= (手動格式化)

return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				-- Go 豪華套餐
				go = { "goimports-reviser", "gofumpt", "golines" },
				-- Java
				java = { "google-java-format" },
				-- Rust
				rust = { "rustfmt" },
				-- Lua
				lua = { "stylua" },
				-- Web 前端
				javascript = { "prettier" },
				typescript = { "prettier" },
				vue = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				-- Python
				python = { "isort", "black" },
				-- C / C++
				c = { "clang-format" },
				cpp = { "clang-format" },
				-- LaTeX
				tex = { "tex-fmt" },
				-- 萬用清理
				-- ["*"] = { "codespell" },
				["_"] = { "trim_whitespace" },
			},
			formatters = {
				["tex-fmt"] = {
					-- 加上 --stdin 確保它是讀取緩衝區內容而非磁碟上的舊檔案
					args = { "--stdin", "--nowrap" },
				},
			},
			-- 存檔自動排版
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000,
			},
		})

		-- 手動格式化熱鍵
		vim.keymap.set({ "n", "v" }, "<leader>=", function()
			require("conform").format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 2000,
			})
		end, { desc = "Format file or range" })
	end,
}
