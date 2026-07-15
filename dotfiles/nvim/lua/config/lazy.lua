-- 🎯 1. 必須在載入 lazy 之前先定義好 Leader Key，確保所有外掛熱鍵正確咬合
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 2. Bootstrap lazy.nvim (自動安裝引信)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- 3. Setup lazy.nvim 核心配置
require("lazy").setup({
	spec = {
		-- 讀取您的 lua/plugins/ 目錄下所有外掛設定檔
		{ import = "plugins" },
	},
	install = { colorscheme = { "habamax" } },
	checker = { enabled = true },

	-- 強制將版本鎖定檔寫入可讀寫的 data 目錄 (~/.local/share/nvim/lazy-lock.json)
	lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})
