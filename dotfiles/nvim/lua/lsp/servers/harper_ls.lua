-- lua/lsp/servers/harper_ls.lua
return function(common)
	-- 定義基礎設定
	local base_cfg = {
		name = "harper_ls",
		cmd = { "harper-ls", "--stdio" },
		filetypes = { "markdown", "gitcommit", "tex", "plaintex", "text" },
		single_file_support = true,
		settings = {
			["harper-ls"] = {
				userDictPath = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
				linters = {
					spell_check = true,
					spelled_numbers = false,
					an_a = true,
					sentence_capitalization = true,
					unclosed_quotes = true,
					long_sentences = true,
					repeated_words = true,
					spaces = true,
					matcher = true,
				},
			},
		},
		-- 繼承您的通用熱鍵 (gd, gr, ...)
		on_attach = common.on_attach,
		capabilities = common.capabilities,
	}

	-- 定義一個專屬的啟動指令 (因為我們不自動啟動)
	vim.api.nvim_create_user_command("HarperStart", function()
		-- 取得當前 buffer
		local bufnr = vim.api.nvim_get_current_buf()

		-- 防止重複啟動
		if #vim.lsp.get_clients({ name = "harper_ls", bufnr = bufnr }) > 0 then
			vim.notify("Harper-ls is already running!", vim.log.levels.WARN)
			return
		end

		-- 啟動 LSP：在這裡動態取得當前目錄的「字串」
		local cfg = vim.tbl_deep_extend("force", base_cfg, {
			bufnr = bufnr,
			-- 關鍵修正：直接傳入 evaluated string，滿足 vim.lsp.start 的嚴格型別要求
			root_dir = vim.fn.getcwd(),
		})

		vim.lsp.start(cfg)
		vim.notify("Harper-ls Started (Style Check)", vim.log.levels.INFO)
	end, { desc = "Manually start Harper LSP" })
end
