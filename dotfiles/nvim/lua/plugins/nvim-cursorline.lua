-- nvim-cursorline 是一個用來高亮當前行的插件，它支持高亮當前行和當前單詞
return {
	"ya2s/nvim-cursorline",
	opts = {
		cursorline = {
			enable = true,
			timeout = 1000,
			number = false,
		},
		cursorword = {
			enable = true,
			min_length = 3,
			hl = { underline = true },
		},
	},
}
