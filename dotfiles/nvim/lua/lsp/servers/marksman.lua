-- lua/lsp/servers/marksman.lua
-- Markdown LSP：Marksman
return function(common)
	local util = require("lspconfig.util")

	local base_cfg = {
		name = "marksman",
		cmd = { "marksman" },
		filetypes = { "markdown", "markdown.mdx" },
		single_file_support = true,
		on_attach = common.on_attach,
		capabilities = common.capabilities,
	}

	-- 自動在 FileType=markdown 啟動
	vim.api.nvim_create_autocmd("FileType", {
		pattern = base_cfg.filetypes,
		callback = function(ev)
			-- 若 buffer 已經有 marksman client，就不重啟
			if #vim.lsp.get_clients({ name = base_cfg.name, bufnr = ev.buf }) > 0 then
				return
			end

			local fname = vim.api.nvim_buf_get_name(ev.buf)
			local uv = vim.uv or vim.loop

			-- 計算專案根目錄：優先找 .marksman.toml 或 .git，找不到則 Fallback 至 cwd (支援未存檔新 Buffer)
			local root
			if fname ~= "" then
				root = util.root_pattern(".marksman.toml", ".git")(fname)
			end
			root = root or uv.cwd()

			vim.lsp.start(vim.tbl_deep_extend("force", base_cfg, {
				root_dir = root,
				bufnr = ev.buf,
			}))
		end,
	})
end
