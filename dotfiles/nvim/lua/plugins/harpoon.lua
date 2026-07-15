-- harpoon.nvim 是一個書籤管理插件，可以快速跳轉到你的書籤位置
-- 熱鍵設定：
-- - <localleader>ba: 加入目前檔案為書籤
-- - <localleader>bl: 打開 Harpoon 書籤清單
-- - <localleader>b1: 跳到書籤 1
-- - <localleader>b2: 跳到書籤 2
-- - <localleader>b3: 跳到書籤 3
-- - <localleader>b4: 跳到書籤 4
-- - 在 Harpoon 清單中，可以使用上下鍵或 j/k 鍵來導航，使用 dd 鍵來刪除書籤
return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = "VeryLazy",

	opts = {
		settings = {
			save_on_toggle = true, -- 開關 quick menu 時自動保存
		},
		menu = {
			width = vim.api.nvim_win_get_width(0) - 4, -- 自動調整 menu 寬度
		},
	},

	config = function(_, opts)
		local harpoon = require("harpoon")
		harpoon:setup(opts)
	end,

	keys = {
		-- 加入書籤
		{
			"<localleader>ba",
			function()
				require("harpoon"):list():add()
				vim.notify("📌 加入書籤: " .. vim.fn.expand("%"), vim.log.levels.INFO, { title = "Harpoon" })
			end,
			desc = "加入目前檔案為書籤",
		},

		-- 顯示 quick menu（支援上下鍵、j/k、刪除dd）
		{
			"<localleader>bl",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "打開 Harpoon 書籤清單",
		},

		-- 快速跳轉到第 1～4 書籤
		{
			"<localleader>b1",
			function()
				require("harpoon"):list():select(1)
			end,
			desc = "跳到書籤 1",
		},
		{
			"<localleader>b2",
			function()
				require("harpoon"):list():select(2)
			end,
			desc = "跳到書籤 2",
		},
		{
			"<localleader>b3",
			function()
				require("harpoon"):list():select(3)
			end,
			desc = "跳到書籤 3",
		},
		{
			"<localleader>b4",
			function()
				require("harpoon"):list():select(4)
			end,
			desc = "跳到書籤 4",
		},
	},
}
