-- fidget 是一個通知和 LSP 進度訊息的可擴展 UI
return {
	"j-hui/fidget.nvim",
	opts = {
		-- 1. 整合通知視窗設定
		notification = {
			window = {
				winblend = 0, -- 設為 0 表示不透明 (如果您想要半透明可設為 10-30)
				border = "rounded", -- 關鍵：加上圓角邊框
				x_padding = 1, -- 文字離邊框留點呼吸空間
			},
		},

		-- 2. 進度條顯示設定
		progress = {
			display = {
				-- 換一個帥氣的載入動畫
				-- 可選：'dots', 'dots_negative', 'pipe', 'bar', 'moon', 'clock'
				progress_icon = { pattern = "moon", period = 1 },

				-- 完成時顯示的圖示 (打勾)
				done_icon = "✔",

				-- 進度條完成後，停留多久才消失 (秒)
				done_ttl = 1,

				-- 3. 自定義格式：讓 LSP 名字 (如 'jdtls') 顯示得更有質感
				format_message = function(msg)
					if not msg.percentage then
						return msg.message or ""
					end
					-- 格式範例： [50%] Indexing...
					return string.format(" [%3d%%] %s", msg.percentage, msg.message or "")
				end,
			},
		},
	},
}
