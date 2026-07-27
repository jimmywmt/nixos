-- lua/lsp/servers/ltex_ls_plus.lua
-- 手動啟動版（Neovim 0.10+ / 0.11+ 新 API）：不自動掛載、不依賴 lspconfig.setup
return function(_common)
	-- filetype -> languageId 映射（照官方）
	local language_id_mapping = {
		bib = "bibtex",
		pandoc = "markdown",
		plaintex = "tex",
		rnoweb = "rsweave",
		rst = "restructuredtext",
		tex = "latex",
		text = "plaintext",
	}
	local function get_language_id(_, filetype)
		return language_id_mapping[filetype] or filetype
	end

	-- 單檔友善 root：優先用當前檔案資料夾，沒有就 cwd；避免 .git 找不到傳 nil
	local function buffer_root(bufnr)
		bufnr = bufnr or 0
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local uv = vim.uv or vim.loop
		if fname == "" then
			return uv.cwd()
		end
		return vim.fs.dirname(fname)
	end

	-- 基礎組態（固定英文 en-US）
	local base_cfg = {
		name = "ltex_plus",
		cmd = { "ltex-ls-plus" },
		root_dir = buffer_root, -- 不往上找 .git，避免與 texlab 搶 root
		single_file_support = true,
		get_language_id = get_language_id,
		settings = {
			ltex = {
				language = "en-US",
				enabled = {
					"bib",
					"context",
					"gitcommit",
					"html",
					"markdown",
					"org",
					"pandoc",
					"plaintex",
					"quarto",
					"mail",
					"mdx",
					"rmd",
					"rnoweb",
					"rst",
					"tex",
					"latex",
					"text",
					"typst",
					"xhtml",
				},
			},
		},
		on_attach = function(_, bufnr)
			-- 保證看得到診斷（就算全域把 virtual_text 關掉）
			vim.diagnostic.config({
				virtual_text = true,
				underline = true,
				signs = true,
				update_in_insert = false,
			}, bufnr)
		end,
	}

	local function attached(bufnr)
		bufnr = bufnr or 0
		return #vim.lsp.get_clients({ name = base_cfg.name, bufnr = bufnr }) > 0
	end

	local function start(bufnr)
		bufnr = bufnr or 0
		if attached(bufnr) then
			vim.notify("LTeX Plus already attached", vim.log.levels.INFO, { title = "ltex-ls-plus" })
			return
		end
		-- 每次啟動都帶當下 buffer 的 root，避免跨檔共用工作區
		local cfg = vim.tbl_extend("force", base_cfg, { bufnr = bufnr, root_dir = buffer_root(bufnr) })
		vim.lsp.start(cfg)
		vim.notify("LTeX Plus started (en-US)", vim.log.levels.INFO, { title = "ltex-ls-plus" })
	end

	local function stop(bufnr)
		bufnr = bufnr or 0
		local any = false
		for _, c in pairs(vim.lsp.get_clients({ name = base_cfg.name })) do
			if vim.lsp.buf_is_attached(bufnr, c.id) then
				vim.lsp.buf_detach_client(bufnr, c.id)
				any = true
			end
		end
		if any then
			vim.notify("LTeX Plus detached from buffer", vim.log.levels.INFO, { title = "ltex-ls-plus" })
		else
			vim.notify("No LTeX Plus client on this buffer", vim.log.levels.WARN, { title = "ltex-ls-plus" })
		end
	end

	local function toggle(bufnr)
		if attached(bufnr) then
			stop(bufnr)
		else
			start(bufnr)
		end
	end

	-- 純手動：只註冊指令，不做任何自動啟動
	vim.api.nvim_create_user_command("LtexPlusStart", function()
		start(0)
	end, { desc = "Start ltex-ls-plus (en-US) for current buffer" })

	vim.api.nvim_create_user_command("LtexPlusStop", function()
		stop(0)
	end, { desc = "Stop/detach ltex-ls-plus for current buffer" })

	vim.api.nvim_create_user_command("LtexPlusToggle", function()
		toggle(0)
	end, { desc = "Toggle ltex-ls-plus for current buffer" })
end
