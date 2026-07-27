-- R.nvim 是一個用於在 Neovim 中運行 R 語言代碼的插件
-- 熱鍵設定：
-- - <Enter>: 在 R 中運行當前行
-- - <localleader>rf: 啟動 R 的環境
-- - <localleader>rq: 退出 R 的環境
-- - <localleader>rC: 清除 R 環境變數
-- - <localleader>gg: 用來檢查變數前幾行的值
return {
	"R-nvim/R.nvim",
	lazy = false,
	config = function()
		---@type RConfigUserOpts
		local opts = {
			hook = {
				on_filetype = function()
					-- 使用現代化的 vim.keymap.set 代替舊版 api
					local opts_buf = { buffer = true, silent = true }

					vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", opts_buf)
					vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", opts_buf)

					-- 清除 R 環境變數
					vim.keymap.set(
						"n",
						"<localleader>rC",
						"<CMD>RSend rm(list=ls())<CR>",
						vim.tbl_extend("force", opts_buf, { desc = "Clear R Environment Variables" })
					)

					-- 儲存前自動執行 RFormat (需確保 home.nix 已安裝 rPackages.styler)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = 0,
						command = "RFormat",
					})
				end,
			},
			R_args = { "--quiet", "--no-save" },
			min_editor_width = 72,
			rconsole_width = 78,
			objbr_mappings = {
				c = "class",
				["<localleader>gg"] = "head({object}, n = 15)",
				v = function()
					require("r.browser").toggle_view()
				end,
			},
		}

		-- 支援 R_AUTO_START=true nvim 的自動啟動邏輯
		if vim.env.R_AUTO_START == "true" then
			opts.auto_start = "on startup"
			opts.objbr_auto_start = true
		end

		require("r").setup(opts)
	end,
}
