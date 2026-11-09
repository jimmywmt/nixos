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
	build = function()
		local rns_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "R.nvim", "rnvimserver")
		local cflags = "-pthread -O2 -Wall"
		if vim.fn.filereadable("/lib64/ld-linux-x86-64.so.2") == 1 then
			cflags = cflags .. " -Wl,-dynamic-linker,/lib64/ld-linux-x86-64.so.2"
		end
		vim.system({ "make", "clean" }, { cwd = rns_dir }):wait()
		vim.system({ "make", "CFLAGS=" .. cflags }, { cwd = rns_dir }):wait()
	end,
	config = function()
		-- ❄️ NixOS 自癒機制：檢測 rnvimserver 是否因系統更新或垃圾回收導致動態連結失效
		local rns_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "R.nvim", "rnvimserver")
		local rns_bin = vim.fs.joinpath(rns_dir, "rnvimserver")
		if vim.fn.filereadable(rns_bin) == 1 then
			local ok, res = pcall(function()
				return vim.system({ rns_bin }, { stdin = "" }):wait()
			end)
			if not ok or res.code ~= 0 then
				vim.fn.delete(rns_bin)
				if vim.fn.executable("make") == 1 then
					local cflags = "-pthread -O2 -Wall"
					if vim.fn.filereadable("/lib64/ld-linux-x86-64.so.2") == 1 then
						cflags = cflags .. " -Wl,-dynamic-linker,/lib64/ld-linux-x86-64.so.2"
					end
					vim.system({ "make", "CFLAGS=" .. cflags }, { cwd = rns_dir }):wait()
				end
			end
		end

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
