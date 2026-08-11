-- nvim-treesitter 是一個用來提供語法高亮和代碼折疊的插件，它支持多種語言

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup()

		require("nvim-treesitter").install({
			"html",
			"css",
			"vim",
			"lua",
			"javascript",
			"typescript",
			"latex",
			"go",
			"java",
			"r",
			"c",
			"cpp",
			"pug",
			"vue",
			"markdown",
			"markdown_inline",
			"json",
			"yaml",
			"bash",
			"python",
			"csv",
		})
	end,
}
