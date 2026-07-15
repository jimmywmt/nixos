-- fencview 是一個可以查看當前文件的編碼格式的插件
-- 熱鍵設定：
-- <localleader>fv: 查看當前文件的編碼格式
return {
	"mbbill/fencview",
	event = "VeryLazy",
	keys = {
		{ "<localleader>fv", "<CMD>FencView<CR>", desc = "Show File Encoding & Format" },
	},
}
