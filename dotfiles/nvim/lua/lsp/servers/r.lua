-- lua/lsp/servers/r.lua
-- R Language Server (languageserver::run())
return function(common)
	local util = require("lspconfig.util")

	-- 取得系統 PATH 中的 R 執行檔
	local r_bin = vim.g.r_path or vim.fn.exepath("R")
	if r_bin == "" then
		r_bin = "R"
	end

	local base_cfg = {
		name = "r_language_server",
		cmd = { r_bin, "--slave", "-e", "languageserver::run()" },
		filetypes = { "r", "rmd", "quarto", "qmd" },
		single_file_support = true,
		capabilities = common.capabilities,
	}

	vim.api.nvim_create_autocmd("FileType", {
		pattern = base_cfg.filetypes,
		callback = function(ev)
			-- 同一個 buffer 不重複啟動
			if #vim.lsp.get_clients({ name = base_cfg.name, bufnr = ev.buf }) > 0 then
				return
			end

			local fname = vim.api.nvim_buf_get_name(ev.buf)
			local uv = vim.uv or vim.loop

			-- 計算專案根目錄
			local root
			if fname ~= "" then
				root = util.root_pattern(".Rprofile", ".here", "DESCRIPTION", ".git")(fname)
			end
			root = root or uv.cwd()

			vim.lsp.start(vim.tbl_deep_extend("force", base_cfg, {
				root_dir = root,
				bufnr = ev.buf,
				on_attach = function(client, bufnr)
					-- 關閉 R LSP 的格式化能力，避免衝突
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
					if common.on_attach then
						common.on_attach(client, bufnr)
					end
				end,
			}))
		end,
	})
end
