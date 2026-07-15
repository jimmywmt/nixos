-- 基礎設置
require("basic")

-- lazy.nvim
require("config.lazy")

-- 設定顏色主題
vim.cmd("colorscheme everforest")

-- 自動切換根目錄 (Auto Rooter)
-- 這裡定義哪些檔案代表「專案根目錄」（加入了 go.work）
local root_names = { ".git", "go.work", "go.mod", "Cargo.toml", "pom.xml", "build.gradle", "Makefile" }

local root_augroup = vim.api.nvim_create_augroup("MyAutoRoot", {})
vim.api.nvim_create_autocmd("BufEnter", {
	group = root_augroup,
	callback = function(ctx)
		-- 防呆：沒有檔名（如空 Buffer）或非一般檔案（如 NvimTree, Telescope 視窗）就跳過
		if ctx.file == "" or vim.bo[ctx.buf].buftype ~= "" then
			return
		end

		-- 一行直接搞定：往上尋找符合 root_names 的目錄路徑
		local root = vim.fs.root(ctx.file, root_names)

		-- 如果有找到根目錄，就優雅地變更工作目錄
		if root then
			vim.fn.chdir(root)
		end
	end,
})
