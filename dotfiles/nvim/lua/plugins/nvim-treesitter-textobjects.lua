-- nvim-treesitter-textobjects 是一個用來擴展nvim-treesitter的插件，它提供了更多的文本對象
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = { "BufReadPost", "BufNewFile" }, -- 只在打開文件時載入，提高啟動速度
}
