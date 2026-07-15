-- lua/lsp/init.lua
local M = {}

function M.setup()
	-- 強制過濾 Node 25 的實驗性警告
	vim.env.NODE_NO_WARNINGS = "1"

	local common = require("lsp.common")

	local servers = {
		"go",
		-- "python",
		-- "ts",
		-- "vue_ls",
		-- "r",
		"lua",
		-- "ruff",
		-- "marksman",
		-- "clangd",
		-- "cssls",
		-- "texlab",
		-- "ltex",
		-- "harper_ls",
		-- "tailwindcss",
	} -- 想載哪些就列哪些
	for _, name in ipairs(servers) do
		local ok, mod = pcall(require, "lsp.servers." .. name)
		if ok and type(mod) == "function" then
			mod(common) -- 把共用 on_attach/capabilities 傳進去
		else
			vim.notify("LSP module load failed: " .. name, vim.log.levels.WARN)
		end
	end
end

return M
