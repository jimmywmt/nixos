-- lua/lsp/servers/ruff.lua
-- Python 超極速 Linter / Formatter: Ruff (使用內建 ruff server)
return function(common)
	local util = require("lspconfig.util")

	local base_cfg = {
		name = "ruff",
		cmd = { "ruff", "server" },
		filetypes = { "python" },
		single_file_support = true,
		capabilities = common.capabilities,
		init_options = {
			settings = {
				-- 是否允許 Ruff 整理 import (若想讓 Pyright 或手動控制可設 false)
				organizeImports = true,
				-- 額外傳給 ruff 的引數 (例如指定特定的 rule)
				args = {},
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

			-- 搜尋專案根目錄 (.ruff.toml / pyproject.toml / .git)
			local root
			if fname ~= "" then
				root = util.root_pattern("pyproject.toml", "ruff.toml", ".ruff.toml", ".git", "requirements.txt")(fname)
			end
			root = root or uv.cwd()

			vim.lsp.start(vim.tbl_deep_extend("force", base_cfg, {
				root_dir = root,
				bufnr = ev.buf,
				on_attach = function(client, bufnr)
					-- 💡 關鍵：停用 Ruff 的 Hover，避免跟 Pyright 重複跳出視窗
					client.server_capabilities.hoverProvider = false

					if common.on_attach then
						common.on_attach(client, bufnr)
					end
				end,
			}))
		end,
	})
end
