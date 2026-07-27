-- lua/lsp/servers/cssls.lua
-- CSS / SCSS / SASS LSP：vscode-langservers-extracted (cssls)

return function(common)
	local util = require("lspconfig.util")

	local base_cfg = {
		name = "cssls",
		cmd = { "vscode-css-language-server", "--stdio" },
		filetypes = { "css", "scss", "sass" },
		root_markers = { ".git", ".vscode", "package.json" },
		single_file_support = true,
		on_attach = common.on_attach,
		capabilities = common.capabilities,
		settings = {
			css = { validate = true },
			scss = { validate = true },
			sass = { validate = true },
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
			local root = util.root_pattern(unpack(base_cfg.root_markers))(fname) or uv.cwd()

			vim.lsp.start(vim.tbl_deep_extend("force", base_cfg, {
				root_dir = root,
				bufnr = ev.buf,
			}))
		end,
	})
end
