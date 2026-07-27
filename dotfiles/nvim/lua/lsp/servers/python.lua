-- lua/lsp/servers/python.lua
-- Python LSP: Pyright (僅負責型別與定義補全，Linting 交給 Ruff)
return function(common)
	local util = require("lspconfig.util")

	-- 動態尋找最合適的 Python 直譯器路徑 (.venv 優先)
	local function get_python_path(root_dir)
		if not root_dir or root_dir == "" then
			root_dir = (vim.uv or vim.loop).cwd()
		end

		-- 1. 優先檢查專案根目錄下的 .venv
		local venv_python = root_dir .. "/.venv/bin/python"
		if vim.fn.executable(venv_python) == 1 then
			return venv_python
		end

		-- 2. 檢查 VIRTUAL_ENV 環境變數 (支援 direnv / nix develop / poetry shell)
		local env_venv = os.getenv("VIRTUAL_ENV")
		if env_venv and vim.fn.executable(env_venv .. "/bin/python") == 1 then
			return env_venv .. "/bin/python"
		end

		-- 3. Fallback: 使用系統 PATH 中的 python3
		local sys_python = vim.fn.exepath("python3")
		if sys_python ~= "" then
			return sys_python
		end

		return "python"
	end

	local base_cfg = {
		name = "pyright",
		cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
		on_attach = common.on_attach,
		capabilities = common.capabilities,
		flags = { debounce_text_changes = 150 },
	}

	-- 自動在 python 檔案開啟時啟動 Pyright
	vim.api.nvim_create_autocmd("FileType", {
		pattern = base_cfg.filetypes,
		callback = function(ev)
			if #vim.lsp.get_clients({ name = base_cfg.name, bufnr = ev.buf }) > 0 then
				return
			end

			local fname = vim.api.nvim_buf_get_name(ev.buf)
			local uv = vim.uv or vim.loop
			local root = util.root_pattern(
				".venv",
				"pyproject.toml",
				"setup.py",
				"setup.cfg",
				"requirements.txt",
				".git"
			)(fname) or uv.cwd()
			local python_bin = get_python_path(root)

			local dynamic_cfg = vim.tbl_deep_extend("force", base_cfg, {
				root_dir = root,
				bufnr = ev.buf,
				settings = {
					python = {
						pythonPath = python_bin,
						analysis = {
							typeCheckingMode = "off", -- 關閉型別檢查，保持潔癖與速度，交給 ruff/pyright 基礎跳轉即可
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "openFilesOnly",
						},
					},
				},
			})

			vim.lsp.start(dynamic_cfg)
		end,
	})
end
