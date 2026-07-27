-- lua/lsp/servers/volar.lua
-- Vue LSP: Volar (Hybrid Mode - 僅負責 Template & Style 區塊)
return function(common)
	local util = require("lspconfig.util")

	local base_cfg = {
		name = "volar",
		cmd = { "vue-language-server", "--stdio" },
		filetypes = { "vue" },
		single_file_support = true,
		capabilities = common.capabilities,
		on_attach = common.on_attach,
		-- 💡 宣告 Hybrid Mode，自動把 JS/TS 型別運算讓位給 ts_ls
		init_options = {
			vue = {
				hybridMode = true,
			},
		},
	}

	vim.api.nvim_create_autocmd("FileType", {
		pattern = base_cfg.filetypes,
		callback = function(ev)
			if #vim.lsp.get_clients({ name = base_cfg.name, bufnr = ev.buf }) > 0 then
				return
			end

			local fname = vim.api.nvim_buf_get_name(ev.buf)
			local uv = vim.uv or vim.loop

			local root
			if fname ~= "" then
				root = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(fname)
			end
			root = root or uv.cwd()

			vim.lsp.start(vim.tbl_deep_extend("force", base_cfg, {
				root_dir = root,
				bufnr = ev.buf,
			}))
		end,
	})
end
