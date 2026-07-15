-- nvim-lspconfig 是一個用來設定和管理 LSP 的插件，它支持多種語言和 LSP 服務器
-- 熱鍵設定：
-- - <localleader>rn: 重命名
-- - <localleader>xa: 代碼操作
-- - gd: 跳轉到定義
-- - gh: Hover 說明
-- - gD: 跳轉到聲明
-- - gi: 跳轉到實現
-- - gr: 查找引用
-- - go: 打開診斷資訊
-- - g[: 上一個診斷
-- - g]: 下一個診斷
-- - gl: 顯示大綱
-- - gci: 顯示呼叫
-- - gco: 顯示被呼叫
return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("lsp").setup()
	end,
}
