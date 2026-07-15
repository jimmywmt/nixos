return {
	"echasnovski/mini.align",
	version = false, -- 使用最新開發版以獲取最佳效能
	config = function()
		require("mini.align").setup({
			-- 對齊觸發鍵，預設就是 ga 與 gA，完美接管 EasyAlign 的習慣
			mappings = {
				start = "ga",
				start_with_preview = "gA",
			},
			-- 如果您有特殊需求，可以在這裡自定義對齊邏輯
			-- 但預設已經包含 & (LaTeX) 和 = (Go/Rust) 等常用符號
		})
	end,
}
