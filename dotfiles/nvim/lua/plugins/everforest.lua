return {
	"sainnhe/everforest",
	event = "VeryLazy",
	config = function()
		-- 設定 everforest 主題的對比度與效能優化
		vim.g.everforest_background = "medium" -- 可選 'hard', 'medium'（預設）, 'soft'
		vim.g.everforest_better_performance = 1
		-- 啟用斜體字 (針對註解和關鍵字)，這在論文寫作時很有語意感
		vim.g.everforest_enable_italic = 1
		vim.g.everforest_ui_contrast = "high" -- 讓介面邊框清楚一點
	end,
}
