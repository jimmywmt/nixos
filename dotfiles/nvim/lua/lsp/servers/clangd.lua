-- lua/lsp/servers/clangd.lua
-- Clangd LSP（C/C++）
return function(common)
	local util = require("lspconfig.util")

	local base_cfg = {
		name = "clangd",
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy", -- 💡 開啟全方位靜態代碼分析 (Linter)
			"--completion-style=detailed", -- 💡 顯示詳細補全資訊 (如函式簽名)
			"--header-insertion=iwyu", -- 💡 補全時自動導入必要的 #include (Include What You Use)
			"--header-insertion-decorators",
		},
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
		single_file_support = true,
		on_attach = common.on_attach,
		capabilities = common.capabilities,
	}

	-- 自動啟動於 C/C++ buffer
	vim.api.nvim_create_autocmd("FileType", {
		pattern = base_cfg.filetypes,
		callback = function(ev)
			if #vim.lsp.get_clients({ name = base_cfg.name, bufnr = ev.buf }) > 0 then
				return
			end

			local fname = vim.api.nvim_buf_get_name(ev.buf)
			local uv = vim.uv or vim.loop
			local root = util.root_pattern("compile_commands.json", "compile_flags.txt", ".clangd", ".git")(fname)
				or uv.cwd()

			vim.lsp.start(vim.tbl_deep_extend("force", base_cfg, {
				root_dir = root,
				bufnr = ev.buf,
			}))
		end,
	})
end
