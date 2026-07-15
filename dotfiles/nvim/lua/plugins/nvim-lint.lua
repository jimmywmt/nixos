-- nvim-lint: 專注於程式碼檢查 (Linter) 的插件
-- 取代 none-ls 的 diagnostics 功能
-- 它是非同步執行的，不會卡住編輯器

return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- 設定各種檔案類型的 linter
		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			vue = { "eslint_d" },
		}

		-- 建立 Autocommand 來觸發 lint
		-- 當進入 Buffer、寫入檔案、或是離開插入模式時觸發
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		-- 綁定一個熱鍵手動觸發 lint (選用)
		vim.keymap.set("n", "<localleader>l", function()
			lint.try_lint()
		end, { desc = "Trigger linting" })
	end,
}
