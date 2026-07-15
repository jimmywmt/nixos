-- marks.nvim 是一個用來快速跳轉到標記的插件，它支持多種標記，並且可以自定義標記符號
-- 熱鍵設定：
-- - m,: 設置下一個可用標記
-- - m;: 開關下一個可用標記
-- - dmx: 刪除x標記
-- - dm-: 刪除當前行所有標記
-- - dm<space>: 刪除當前buffer所有標記
return {
	"chentoast/marks.nvim",
	event = "VeryLazy",
	opts = {},
}
